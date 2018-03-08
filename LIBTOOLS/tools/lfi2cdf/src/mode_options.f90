module mode_options
  USE MODD_PARAM

  implicit none

  integer,parameter :: nbavailoptions = 8
  integer,parameter :: MODEUNDEF = -11, MODECDF2CDF = 11, MODELFI2CDF = 12, MODECDF2LFI = 13

  integer,parameter :: OPTCOMPRESS = 1, OPTHELP   = 2, OPTLIST   = 3
  integer,parameter :: OPTMERGE    = 4, OPTOUTPUT = 5, OPTREDUCE = 6
  integer,parameter :: OPTSPLIT    = 7, OPTVAR    = 8

  type option
    logical :: set = .false.
    character(len=:),allocatable :: long_name
    character :: short_name
    logical :: has_argument
    integer :: type = TYPEUNDEF
    integer :: ivalue
    logical :: lvalue
    real    :: rvalue
    character(len=:),allocatable :: cvalue
  end type option

contains
subroutine read_commandline(options,hinfile,houtfile,runmode)
  implicit none

  type(option),dimension(:),allocatable,intent(out) :: options
  character(len=:),allocatable,intent(out)          :: hinfile
  character(len=:),allocatable,intent(out)          :: houtfile
  integer,intent(out)                               :: runmode

  integer :: idx, nbargs, status, sz
  logical :: finished
  character(len=:),allocatable :: command, fullcommand


  call GET_COMMAND_ARGUMENT(NUMBER=0,LENGTH=sz)
  allocate(character(len=sz)::fullcommand)
  call GET_COMMAND_ARGUMENT(NUMBER=0,VALUE=fullcommand)

  idx = index(fullcommand,'/',back=.true.)
  allocate(character(len=sz-idx)::command)
  command=fullcommand(idx+1:)

  select case (command)
    case ('cdf2cdf')
      runmode = MODECDF2CDF
    case ('cdf2lfi')
      runmode = MODECDF2LFI
    case ('lfi2cdf')
      runmode = MODELFI2CDF
    case default
      runmode = MODEUNDEF
      print *,'Error: program started with unknown command: ',command
      call help()
  end select
  deallocate(command,fullcommand)

  call init_options(options)

  nbargs = COMMAND_ARGUMENT_COUNT()

  if (nbargs==0) then
    print *,'Error: no input file given'
    call help()
  end if

  if (nbargs>1) then
    finished = .false.
    do while(.not.finished)
      call get_option(options,finished)
    end do
  end if

  call GET_COMMAND_ARGUMENT(NUMBER=nbargs,LENGTH=sz)
  allocate(character(len=sz)::hinfile)
  call GET_COMMAND_ARGUMENT(NUMBER=COMMAND_ARGUMENT_COUNT(),VALUE=hinfile)

  call check_options(options,hinfile,runmode)

  houtfile = options(OPTOUTPUT)%cvalue

  !Remove level in the filename if merging LFI splitted files and output name not set by option
  if (.NOT.options(OPTOUTPUT)%set) then
    if (options(OPTMERGE)%set) then
      houtfile=hinfile(1:len(hinfile)-9)
    end if
  end if

end subroutine read_commandline

subroutine init_options(options)
  implicit none

  type(option),dimension(:),allocatable,intent(out) :: options

  allocate(options(nbavailoptions))

  options(OPTCOMPRESS)%long_name    = "compress"
  options(OPTCOMPRESS)%short_name   = 'c'
  options(OPTCOMPRESS)%has_argument = .true.
  options(OPTCOMPRESS)%type         = TYPEINT

  options(OPTHELP)%long_name    = "help"
  options(OPTHELP)%short_name   = 'h'
  options(OPTHELP)%has_argument = .false.

  options(OPTLIST)%long_name    = "list"
  options(OPTLIST)%short_name   = 'l'
  options(OPTLIST)%has_argument = .false.

  options(OPTMERGE)%long_name    = "merge"
  options(OPTMERGE)%short_name   = 'm'
  options(OPTMERGE)%has_argument = .true.
  options(OPTMERGE)%type         = TYPEINT

  options(OPTOUTPUT)%long_name    = "output"
  options(OPTOUTPUT)%short_name   = 'o'
  options(OPTOUTPUT)%has_argument = .true.
  options(OPTOUTPUT)%type         = TYPECHAR

  options(OPTREDUCE)%long_name    = "reduce-precision"
  options(OPTREDUCE)%short_name   = 'r'
  options(OPTREDUCE)%has_argument = .false.

  options(OPTSPLIT)%long_name    = "split"
  options(OPTSPLIT)%short_name   = 's'
  options(OPTSPLIT)%has_argument = .false.

  options(OPTVAR)%long_name    = "var"
  options(OPTVAR)%short_name   = 'v'
  options(OPTVAR)%has_argument = .true.
  options(OPTVAR)%type         = TYPECHAR

end subroutine init_options

subroutine get_option(options,finished)
  implicit none

  integer,parameter :: MAXARGSIZE=512

  logical,intent(out) :: finished
  type(option),dimension(:),intent(inout) :: options

  integer,save              :: argnum = 1
  integer                   :: i, sz
  logical                   :: found
  character(len=MAXARGSIZE) :: arg

  found = .false.
  call GET_COMMAND_ARGUMENT(NUMBER=argnum,VALUE=arg,LENGTH=sz)
  if(sz>MAXARGSIZE) print *,'Error: argument bigger than ',MAXARGSIZE
  if ( INDEX(arg,'--')==1 .AND. sz>2) then
    do i=1,nbavailoptions
      if (options(i)%long_name == trim(arg(3:))) then
        found = .true.
        exit
      end if
    end do
  else if ( INDEX(arg,'-')==1 ) then
    do i=1,nbavailoptions
      if (options(i)%short_name == trim(arg(2:))) then
        found = .true.
        exit
      end if
    end do
  else
    print *,'Error: ',trim(arg),' is not an option'
    call help()
  end if

  if ( .not.found ) then
    print *,'Error: unknown option: ',trim(arg)
    call help()
  end if

  if (options(i)%set) then
    print *,'Error: at least 1 option is set several times!'
    call help()
  end if

  options(i)%set = .true.
  if (options(i)%has_argument) then
    argnum = argnum + 1
    if (argnum >= COMMAND_ARGUMENT_COUNT()) then
      print *,'Error: argument for option ',trim(arg),' not found'
      call help()
    end if
    call GET_COMMAND_ARGUMENT(NUMBER=argnum,VALUE=arg,LENGTH=sz)
    if(sz>MAXARGSIZE) print *,'Error: argument bigger than ',MAXARGSIZE
    select case (options(i)%type)
      case (TYPEINT)
        read (arg,*) options(i)%ivalue
      case (TYPELOG)
        read (arg,*) options(i)%lvalue
      case (TYPEREAL)
        read (arg,*) options(i)%rvalue
      case (TYPECHAR)
        options(i)%cvalue = arg
      case default
        print *,'Error: unknown option type'
        call help()
    end select
  end if

  argnum = argnum + 1

  if (argnum >= COMMAND_ARGUMENT_COUNT()) finished = .true.

end subroutine get_option

subroutine check_options(options,infile,runmode)
  implicit none

  type(option),dimension(:),intent(inout) :: options
  character(len=:),allocatable,intent(in) :: infile
  integer,intent(in)                      :: runmode

  integer :: idx1, idx2


  !Check if help has been asked
  if (options(OPTHELP)%set) then
    call help()
  end if

  !Check compression level
  if (options(OPTCOMPRESS)%set) then
    if (options(OPTCOMPRESS)%ivalue < 1 .OR. options(OPTCOMPRESS)%ivalue > 9 ) then
      print *,'Error: compression level should in the 1 to 9 interval'
      call help()
    end if
  end if

  !Check list option
  if (options(OPTLIST)%set .AND. runmode/=MODELFI2CDF) then
    print *,'Error: list option is only valid for lfi2cdf'
    call help()
  end if

  !Merge flag only supported if -v is set
  if (options(OPTMERGE)%set .AND. .NOT.options(OPTVAR)%set) then
    print *,'Error: merge option must be used with var option'
    call help()
  end if

  !Split flag only supported if -v is set
  if (options(OPTSPLIT)%set .AND. .NOT.options(OPTVAR)%set) then
      options(OPTSPLIT)%set = .false.
      print *,"Warning: split option is forced to disable"
  end if

  !Determine outfile name if not given
  if (.NOT.options(OPTOUTPUT)%set) then
    idx1 = index(infile,'/',back=.true.)
    idx2 = index(infile,'.',back=.true.)
    options(OPTOUTPUT)%cvalue = infile(idx1+1:idx2-1)
  end if

end subroutine check_options

subroutine help()
  implicit none

!TODO: -l option for cdf2cdf and cdf2lfi
  print *,"Usage : lfi2cdf [-h --help] [-l] [-v --var var1[,...]] [-r --reduce-precision]"
  print *,"                [-m --merge number_of_z_levels] [-s --split] [-o --output output-file.nc]"
  print *,"                [-c --compress compression_level] input-file.lfi"
  print *,"        cdf2cdf [-h --help] [-v --var var1[,...]] [-r --reduce-precision]"
  print *,"                [-m --merge number_of_z_levels] [-s --split] [-o --output output-file.nc]"
  print *,"                [-c --compress compression_level] input-file.nc"
  print *,"        cdf2lfi [-o --output output-file.lfi] input-file.nc"
  print *,""
  print *,"Options:"
  print *,"  --compress, -c compression_level"
  print *,"     Compress data. The compression level should be in the 1 to 9 interval."
  print *,"     Only supported with the netCDF-4 format (cdf2cdf and lfi2cdf only)"
  print *,"  --help, -h"
  print *,"     Print this text"
  print *,"  --list, -l"
  print *,"     List all the fields of the LFI file and returns (lfi2cdf only)"
  print *,"  --merge, -m number_of_z_levels"
  print *,"     Merge LFI files which are split by vertical level (cdf2cdf and lfi2cdf only)"
  print *,"  --output, -o"
  print *,"     Name of file for the output"
  print *,"  --reduce-precision, -r"
  print *,"     Reduce the precision of the floating point variables to single precision (cdf2cdf and lfi2cdf only)"
  print *,"  --split, -s"
  print *,"     Split variables specified with the -v option (one per file) (cdf2cdf and lfi2cdf only)"
  print *,"  --var, -v var1[,...]"
  print *,"     List of the variable to write in the output file. Variables names have to be separated by commas (,)."
  print *,"     A variable can be computed from the sum of existing variables (format: new_var=var1+var2[+...])"
  print *,"     (cdf2cdf and lfi2cdf only)"
  print *,""
  stop

end subroutine help

end module mode_options
