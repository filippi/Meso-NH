#!/bin/bash

#set -x
set -e
set -o pipefail #abort if left command on a pipe fails

#The folowing environment variables can be defined:
# REFDIR: directory in which the reference compilation directory can be found
# TARGZDIR: directory where tar.gz files are searched for
# MNHPACK: directory where tests are build

availTests="007_16janvier/008_run2, 007_16janvier/008_run2_turb3D, 007_16janvier/008_run2_lredf, COLD_BUBBLE/002_mesonh, 
            ARMLES/RUN, COLD_BUBBLE_3D/002_mesonh,OCEAN_LES/004_run2,014_LIMA/002_mesonh"
defaultTest="007_16janvier/008_run2"
separator='_' #- be carrefull, gmkpack (at least on belenos) has multiple allergies (':', '.', '@')
              #- seprator must be in sync with prep_code.sh separator

PHYEXTOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
function usage {
  echo "Usage: $0 [-h] [-c] [-r] [-C] [-s] [--expand] [-t test] [--remove] commit [reference]"
  echo "commit          commit hash (or a directory)"
  echo "reference       commit hash or a directory or nothing for ref"
  echo "-s              suppress compilation pack"
  echo "-c              performs compilation"
  echo "-r              runs the tests"
  echo "-C              checks the result against the reference"
  echo "-t              comma separated list of tests to execute"
  echo "                or ALL to execute all tests"
  echo "--expand        use mnh_expand (code will use do loops)"
  echo "--repo-user     user hosting the PHYEX repository on github,"
  echo "                defaults to the env variable PHYEXREOuser (=$PHYEXREOuser)"
  echo "--repo-protocol protocol (https or ssh) to reach the PHYEX repository on github,"
  echo "                defaults to the env variable PHYEXREOprotocol (=$PHYEXREOprotocol)"
  echo "--remove        removes the pack"
  echo ""
  echo "If nothing is asked (compilation, running, check, removing) everything"
  echo "except the removing is done"
  echo
  echo "If no test is aked for, the default one ($defaultTest) is executed"
  echo
  echo "With the special reference REF commit, a suitable reference is guessed"
  echo
  echo "The directory (for commit only, not ref) can take the form server:directory"
  echo
  echo "If using a directory (for commit or reference) it must contain at least one '/'"
  echo "The commit can be a tag, written with syntagx tags/<TAG>"
}

compilation=0
run=0
check=0
commit=""
reference=""
tests=""
suppress=0
useexpand=0
remove=0

while [ -n "$1" ]; do
  case "$1" in
    '-h') usage;;
    '-s') suppress=1;;
    '-c') compilation=1;;
    '-r') run=$(($run+1));;
    '-C') check=1;;
    '-t') tests="$2"; shift;;
    '--expand') useexpand=1;;
    '--repo-user') export PHYEXREPOuser=$2; shift;;
    '--repo-protocol') export PHYEXREPOprotocol=$2; shift;;
    '--remove') remove=1;;
    #--) shift; break ;;
     *) if [ -z "${commit-}" ]; then
          commit=$1
        else
          if [ -z "${reference-}" ]; then
            reference=$1
          else
            echo "Only two commit hash allowed on command line"
            exit 1
          fi
        fi;;
  esac
  shift
done

[ "$reference" == 'REF' ] && reference="" #Compatibility with check_commit_arome.sh

MNHPACK=$HOME/MNHTESTING/MesoNH
REFDIR=$HOME/REF
TARGZDIR=$HOME
if [ -z "${tests-}" ]; then
  tests=$defaultTest
elif [ $tests == 'ALL' ]; then
  tests=$availTests
fi

if [ $compilation -eq 0 -a \
     $run -eq 0 -a \
     $check -eq 0 -a \
     $remove -eq 0 ]; then
  compilation=1
  run=1
  check=1
fi

if [ -z "${commit-}" ]; then
  echo "At least one commit hash must be provided on command line"
  exit 2
fi

#Name, directory and reference for compiling and executing user pack
#Recuperation de la version (TODO from a Json file)
#if echo $commit | grep '/' | grep -v '^tags/' > /dev/null; then
#  fromdir=$commit
#  content_mesonh_version=$(scp $commit/src/mesonh/mesonh_version.json /dev/stdout 2>/dev/null || echo "")
#else
#  fromdir=''
#  if [[ $commit == mesonh${separator}* ]]; then
#    mesonh_version_file="mesonh_version.json"
#  else
#    mesonh_version_file="src/mesonh/mesonh_version.json"
#  fi
#  if echo $commit | grep '^tags/' > /dev/null; then
#    urlcommit=$(echo $commit | cut -d / -f 2-)
#  else
#    urlcommit=$commit
#  fi
#  content_mesonh_version=$(wget --no-check-certificate https://raw.githubusercontent.com/$PHYEXREPOuser/PHYEX/${urlcommit}/$mesonh_version_file -O - 2>/dev/null || echo "")
#fi
#refversion=$(content_mesonh_version=$content_mesonh_version python3 -c "import json, os; v=os.environ['content_mesonh_version']; print(json.loads(v if len(v)!=0 else '{}').get('refversion', 'MNH-V5-6-0'))")

refversion=MNH-V5-6-0

tag=$(echo $commit | sed 's/\//'${separator}'/g' | sed 's/:/'${separator}'/g' | sed 's/\./'${separator}'/g')
name=${refversion}-$tag
[ $suppress -eq 1 -a -d $MNHPACK/$name ] && rm -rf $MNHPACK/$name

#Two possibilities are supported for the simulations
# - they can be done in the the pack we are currently checking
# - they can be done in the reference pack
#They are done in the current pack except if the reference pack
#already contains a tested simulation
#To check this, we use the case 007_16janvier/008_run2_turb3D
if [ $(ls -d $REFDIR/${refversion}/MY_RUN/KTEST/007_16janvier/008_run2_turb3D_* 2> /dev/null | wc -l) -gt 0 ]; then
  run_in_ref=1
else
  run_in_ref=0
fi
if [ $run_in_ref -eq 1 ]; then
  path_user_beg=$REFDIR/${refversion} #pack directory containing the simulation
  path_user_end=_$tag #to be appended to the 'run' simulation directory
else
  path_user_beg=$MNHPACK/$name #pack directory containing the simulation
  path_user_end= #to be appended to the 'run' simulation directory
fi

#Name and directory for the reference
reffromdir=''
if echo $reference | grep '/' > /dev/null; then
  reffromdir=$reference
  reftag=$(echo $reference | sed 's/\//'${separator}'/g' | sed 's/:/'${separator}'/g' | sed 's/\./'${separator}'/g')
else
  reftag=$reference
fi
refname=${refversion}-$reftag
if [ $run_in_ref -eq 1 ]; then
  path_ref_beg=$REFDIR/${refversion}
  if [ "$reference" == "" ]; then
    path_ref_end=
  else
    path_ref_end=_$reftag
  fi
else
  path_ref_end=
  if [ "$reference" == "" ]; then
    path_ref_beg=$REFDIR/${refversion}
  else
    path_ref_beg=$MNHPACK/${refversion}-$reftag
  fi
fi

if [ $compilation -eq 1 ]; then
  echo "### Compilation of commit $commit"

  if [ -d $MNHPACK/$name ]; then
    echo "Pack already exists ($MNHPACK/$name), suppress it to be able to compile it again (or use the -s option to automatically suppress it)"
    exit 5
  fi

  # Prepare the pack
  cd $MNHPACK
  cp $TARGZDIR/${refversion}.tar.gz .
  tar xfz ${refversion}.tar.gz 
  rm ${refversion}.tar.gz
  mv ${refversion} $name
  cd $name/src
  # Routine that changed names
  
  #Configure and compilation
  command -v module && modulelist=$(module -t list 2>&1 | tail -n +2) #save loaded modules
  ./configure
  set +e #file ends with a test that can return false
  . ../conf/profile_mesonh-* #This lines modifies the list of loaded modules
  set -e
  rm -f ../exe/* #Suppress old executables, if any
  make -j 8 2>&1 | tee ../Output_compilation
  make installmaster 2>&1 | tee -a ../Output_compilation
  command -v module && module load $modulelist #restore loaded modules
fi

if [ $run -ge 1 ]; then
  echo "### Running of commit $commit"

  if [ ! -f $MNHPACK/$name/exe/MESONH* ]; then
    echo "Pack does not exist ($MNHPACK/$name) or compilation has failed, please check"
    exit 6
  fi

  for t in $(echo $tests | sed 's/,/ /g'); do
    case=$(echo $t | cut -d / -f 1)
    exedir=$(echo $t | cut -d / -f 2)
    if [ $run_in_ref -eq 1 ]; then
      cd $REFDIR/${refversion}/MY_RUN/KTEST/$case/
      [ ! -d ${exedir}_$commit ] && cp -R ${exedir} ${exedir}_$commit
      cd $REFDIR/${refversion}/MY_RUN/KTEST/$case/${exedir}_$commit
    else
      #If the test case didn't exist in the tar.gz, we copy it from from the reference version
      rep=$MNHPACK/$name/MY_RUN/KTEST/$case
      [ ! -d $rep ] && cp -r $REFDIR/${refversion}/MY_RUN/KTEST/$case $rep
      cd $rep

      #Loop on the directories
      for rep in *; do
        if [[ -d "$rep" || ( -L "$rep" && ! -e "$rep" ) ]]; then #directory (or a link to a directory) or a broken link
          if echo $availTests | grep ${case}/$rep > /dev/null; then
            #This directory is a test case
            if [ $rep == ${exedir} ]; then
              #this is the case we want to run
              rm -rf $rep
              cp -r $REFDIR/${refversion}/MY_RUN/KTEST/$case/$rep .
            fi
          else
            #This directory might be neede to run the test case, we take the reference version
            rm -rf $rep
            ln -s $REFDIR/${refversion}/MY_RUN/KTEST/$case/$rep 
          fi
        fi
      done

      #In case subcase does not exist we create it
      [ ! -d ${exedir} ] && cp -r $REFDIR/${refversion}/MY_RUN/KTEST/$case/${exedir} .
      cd ${exedir}
    fi

    set +e #file ends with a test that can return false
    [ $compilation -eq 0 ] && . $MNHPACK/$name/conf/profile_mesonh-*
    set -e
    ./clean_mesonh_xyz
    set +o pipefail #We want to go through all tests
    ./run_mesonh_xyz | tee Output_run
    set -o pipefail
  done
fi

if [ $check -eq 1 ]; then
  echo "### Check commit $commit against commit $reference"

  allt=0
  for t in $(echo $tests | sed 's/,/ /g'); do
    case=$(echo $t | cut -d / -f 1)
    exedir=$(echo $t | cut -d / -f 2)
    if [ $t == 007_16janvier/008_run2 ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/007_16janvier/008_run2$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/007_16janvier/008_run2$path_ref_end
    elif  [ $t == 007_16janvier/008_run2_turb3D ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/007_16janvier/008_run2_turb3D$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/007_16janvier/008_run2_turb3D$path_ref_end
    elif  [ $t == 007_16janvier/008_run2_lredf ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/007_16janvier/008_run2_lredf$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/007_16janvier/008_run2_lredf$path_ref_end
    elif   [ $t == COLD_BUBBLE/002_mesonh ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/COLD_BUBBLE/002_mesonh$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/COLD_BUBBLE/002_mesonh$path_ref_end
    elif   [ $t == COLD_BUBBLE_3D/002_mesonh ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/COLD_BUBBLE_3D/002_mesonh$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/COLD_BUBBLE_3D/002_mesonh$path_ref_end
    elif   [ $t == ARMLES/RUN ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/ARMLES/RUN$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/ARMLES/RUN$path_ref_end
    elif   [ $t == OCEAN_LES/004_run2 ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/OCEAN_LES/004_run2$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/OCEAN_LES/004_run2$path_ref_end
    elif   [ $t == 014_LIMA/002_mesonh ]; then
      path_user=$path_user_beg/MY_RUN/KTEST/014_LIMA/002_mesonh$path_user_end
      path_ref=$path_ref_beg/MY_RUN/KTEST/014_LIMA/002_mesonh$path_ref_end
    else
      echo "cas $t non reconnu"
    fi

    if [ ! -d $path_user ]; then
      echo "$path_user is missing, please run the simulation"
      exit 7
    fi
    if [ ! -d $path_ref ]; then
      echo "$path_ref is missing, please run the reference simulation"
      exit 8
    fi

    if [ $case == 007_16janvier ]; then
      # Compare variable of both Synchronous and Diachronic files with printing difference
      file1=$path_user/16JAN.1.12B18.001.nc 
      file2=$path_ref/16JAN.1.12B18.001.nc
      file3=$path_user/16JAN.1.12B18.000.nc 
      file4=$path_ref/16JAN.1.12B18.000.nc
      if [ -f $file1 -a -f $file2 ]; then
        echo "Compare with python..."
        set +e
        $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2 --f3 $file3 --f4 $file4
        t=$?
        set -e
        allt=$(($allt+$t))
        
        #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
        echo "Compare with ncdump..."
        set +e
        bit_diff=57100
        diff <(ncdump $file1 | head -c $bit_diff) <(ncdump $file2 | head -c $bit_diff)
        t=$?
        set -e
        allt=$(($allt+$t))
      else
        [ ! -f $file1 ] && echo "  $file1 is missing"
        [ ! -f $file2 ] && echo "  $file2 is missing"
        allt=$(($allt+1))
      fi
    fi

    if [ $case == COLD_BUBBLE ]; then
      # Compare variable of both Synchronous files with printing difference
      file1=$path_user/BUBBL.1.CEN4T.001.nc
      file2=$path_ref/BUBBL.1.CEN4T.001.nc
      if [ -f $file1 -a -f $file2 ]; then
        echo "Compare with python..."
        set +e
        $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2
        t=$?
        set -e
        allt=$(($allt+$t))
        
        #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
        echo "Compare with ncdump..."
        set +e
        bit_diff=27300
        diff <(ncdump $file1 | head -c $bit_diff) <(ncdump $file2 | head -c $bit_diff)
        t=$?
        set -e
        allt=$(($allt+$t))
      else
        [ ! -f $file1 ] && echo "  $file1 is missing"
        [ ! -f $file2 ] && echo "  $file2 is missing"
        allt=$(($allt+1))
      fi
    fi

   if [ $case == OCEAN_LES ]; then
        # Compare variable of both Synchronous files with printing difference
        file1=$path_user/SPWAN.2.25m00.001.nc
        file2=$path_ref/SPWAN.2.25m00.001.nc
        if [ -f $file1 -a -f $file2 ]; then
          echo "Compare with python..."
          set +e
          $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2
          t=$?
          set -e
          allt=$(($allt+$t))
  
          #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
          echo "Compare with ncdump..."
          set +e
          bit_diff=18400
          diff <(ncdump $file1 | head -c $bit_diff) <(ncdump $file2 | head -c $bit_diff)
          t=$?
          set -e
          allt=$(($allt+$t))
        else
          [ ! -f $file1 ] && echo "  $file1 is missing"
          [ ! -f $file2 ] && echo "  $file2 is missing"
          allt=$(($allt+1))
        fi
      fi

    if [ $case == COLD_BUBBLE_3D ]; then
      # Compare variable of both Synchronous and Diachronic files with printing difference
      file1=$path_user/BUBBL.1.CEN4T.001.nc
      file2=$path_ref/BUBBL.1.CEN4T.001.nc
      file3=$path_user/BUBBL.1.CEN4T.000.nc
      file4=$path_ref/BUBBL.1.CEN4T.000.nc
      if [ -f $file1 -a -f $file2 ]; then
        echo "Compare with python..."
        set +e
        $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2 --f3 $file3 --f4 $file4
        t=$?
        set -e
        allt=$(($allt+$t))

        #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
        echo "Compare with ncdump..."
        set +e
        diff <(ncdump $file1 | head -c 27300) <(ncdump $file2 | head -c 27300)
        t=$?
        set -e
        allt=$(($allt+$t))
      else
        [ ! -f $file1 ] && echo "  $file1 is missing"
        [ ! -f $file2 ] && echo "  $file2 is missing"
        allt=$(($allt+1))
      fi
    fi

    if [ $case == ARMLES ]; then
      # Compare variable of both Synchronous and Diachronic files with printing difference
      file1=$path_user/ARM__.1.CEN4T.001.nc
      file2=$path_ref/ARM__.1.CEN4T.001.nc
      file3=$path_user/ARM__.1.CEN4T.000.nc
      file4=$path_ref/ARM__.1.CEN4T.000.nc
      if [ -f $file1 -a -f $file2 ]; then
        echo "Compare with python..."
        set +e
        $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2 --f3 $file3 --f4 $file4
        t=$?
        set -e
        allt=$(($allt+$t))

        #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
        echo "Compare with ncdump..."
        set +e
        bit_diff=76300
        diff <(ncdump $file1 | head -c $bit_diff) <(ncdump $file2 | head -c $bit_diff)
        t=$?
        set -e
        allt=$(($allt+$t))
      else
        [ ! -f $file1 ] && echo "  $file1 is missing"
        [ ! -f $file2 ] && echo "  $file2 is missing"
        allt=$(($allt+1))
      fi
    fi

    if [ $case == 014_LIMA ]; then
      # Compare variable of both Synchronous and Diachronic files with printing difference
      file1=$path_user/XPREF.1.SEG01.002.nc
      file2=$path_ref/XPREF.1.SEG01.002.nc
      file3=$path_user/XPREF.1.SEG01.000.nc
      file4=$path_ref/XPREF.1.SEG01.000.nc
      if [ -f $file1 -a -f $file2 ]; then
        echo "Compare with python..."
        set +e
        $PHYEXTOOLSDIR/compare.py --f1 $file1 --f2 $file2 --f3 $file3 --f4 $file4
        t=$?
        set -e
        allt=$(($allt+$t))

        #Check bit-repro before date of creation of Synchronous file from ncdump of all values (pb with direct .nc file checks)
        echo "Compare with ncdump..."
        set +e
        bit_diff=32200
        diff <(ncdump $file1 | head -c $bit_diff) <(ncdump $file2 | head -c $bit_diff)
        t=$?
        set -e
        allt=$(($allt+$t))
      else
        [ ! -f $file1 ] && echo "  $file1 is missing"
        [ ! -f $file2 ] && echo "  $file2 is missing"
        allt=$(($allt+1))
      fi
    fi
  done

  if [ $allt -eq 0 ]; then
    status="OK"
  else
    status="Files are different"
    cmpstatus=50
  fi
  echo "...comparison done: $status"
fi

if [ $remove -eq 1 ]; then
  echo "### Remove model directory for commit $commit"
  [ -d $MNHPACK/$name ] && rm -rf $MNHPACK/$name
fi

exit $cmpstatus
