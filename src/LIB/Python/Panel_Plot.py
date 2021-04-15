#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 24 10:49:45 2021

@author: rodierq
"""
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import ListedColormap
import numpy as np
import cartopy.feature as cfeature

class PanelPlot():
    
    def __init__(self, nb_l, nb_c, Lfigsize, bigtitle, titlepad=40, minmaxpad=1.03, timepad=-0.06, lateralminmaxpad=0.86, 
                 labelcolorbarpad=6.0, colorbaraspect=20, colorbarpad=0.04 ):
        self.bigtitle = bigtitle
        self.Lfigsize = Lfigsize
        self.nb_l = nb_l
        self.nb_c = nb_c
        self.nb_graph = 0              #  New independent graph within the subplot
        self.titlepad = titlepad       #  Title pad (vertical shift) from graph
        self.minmaxpad = minmaxpad     #  Min/Max print pad (vertical shift)
        self.timepad = timepad         #  Time print pad (vertical shift)
        self.colorbarpad = colorbarpad #  Colorbar pad (horizontal shift from graph)
        self.lateralminmaxpad = lateralminmaxpad
        self.labelcolorbarpad = labelcolorbarpad # Vertical colorbal label pad
        self.colorbaraspect = colorbaraspect  # Ratio of long to short dimensions of colorbar w.r.t. the figure
        
        #  Initialization of the panel plots
        self.fig = plt.figure(figsize=(self.Lfigsize[0],self.Lfigsize[1]))
        self.fig.set_dpi(400)
        self.fig.suptitle(self.bigtitle,fontsize=16)

    def save_graph(self, iplt, fig):
      """
        Create a temporary png file of (sub)-plot(s) which can be converted to PDF    
      """
      self.iplt = iplt
      self.fig = fig
      
      self.iplt+=1
      self.fig.savefig('tempgraph'+str(self.iplt))
      return self.iplt
    
    def draw_Backmap(self,drawCoastLines, ax, projo):
      """
        Handle drawing of the background plot (coastlines, departements, grid lines and labels)   
      """
      self.drawCoastLines = drawCoastLines
      self.projo = projo
      
        # Grid lines and labels
      if 'PlateCarree' in str(projo):
        gl = ax.gridlines(crs=self.projo, draw_labels=True, linewidth=1, color='gray')
        gl.xlabels_top = False
        gl.ylabels_right = False
        
        #  Coastlines
      if self.drawCoastLines and 'GeoAxes' in str(type(ax)):
        ax.coastlines(resolution='10m')
        
        #  Countries border
        ax.add_feature(cfeature.BORDERS)
        ax.add_feature(cfeature.LAKES, alpha=0.7)
        
    def addWhitecm(self, Laddwhite, colormap_in, nb_level):
      if Laddwhite:
        color_map = cm.get_cmap(colormap_in, 256)
        newcolor_map = color_map(np.linspace(0, 1, 256))
        whites = np.array([1, 1, 1, 1]) #RBG code + opacity
        for i in range(int(256/nb_level)): newcolor_map[:i, :] = whites
        newcmp = ListedColormap(newcolor_map)
      return newcmp


    def set_Title(self, ax, i, title, Lid_overlap, xlab, ylab):
      """
        Handle top title of each graph 
        Parameters :
            - titlepad : global attribute for vertical shift placement w.r.t the graph
      """
      self.ax = ax
      self.title = title
      self.Lid_overlap = Lid_overlap
      self.i = i
      #self.ax[self.i].set_xlabel("test", fontweight='bold')
      if not Lid_overlap: 
        self.ax[self.i].set_title(title, pad=self.titlepad)
      else:  #  If graph overlap, title is concatenated
        new_title = self.ax[self.i].get_title() + ' and ' + title
        self.ax[self.i].set_title(new_title, pad=self.titlepad)

    def set_xlim(self, ax, i, xlim):
      """
       Handle x limits plotted if necessary
      """
      self.ax = ax
      self.xlim = xlim
      self.i = i
      
      self.ax[self.i].set_xlim(xlim[0],xlim[1])
      
    def set_ylim(self, ax, i, ylim):
      """
       Handle x limits plotted if necessary
      """
      self.ax = ax
      self.ylim = ylim
      self.i = i
      
      self.ax[self.i].set_ylim(ylim[0],ylim[1])

    def set_XYaxislab(self, ax, i, xlab, ylab):
      """
        Handle x and y axis labels
      """
      self.ax = ax
      self.xlab = xlab
      self.ylab = ylab
      self.i = i

      #  This handing label is a known issue with GeoAxes of cartopy 
      #  https://stackoverflow.com/questions/35479508/cartopy-set-xlabel-set-ylabel-not-ticklabels
      #  https://github.com/SciTools/cartopy/issues/1332
      if 'GeoAxes' in str(type(self.ax[self.i])):
        self.ax[self.i].text(-0.11, 0.45, ylab, verticalalignment='top', horizontalalignment='left',
              rotation='vertical', rotation_mode='anchor',  transform=self.ax[self.i].transAxes, color='black', fontsize=11)
        self.ax[self.i].text(0.45, -0.06, xlab, verticalalignment='top', horizontalalignment='left',
             rotation='horizontal', rotation_mode='anchor',  transform=self.ax[self.i].transAxes, color='black', fontsize=11)
      else:
         self.ax[self.i].set_xlabel(xlab)
         self.ax[self.i].set_ylabel(ylab)
         
    def addLine(self, ax, beg_coord, end_coord, color='black', linewidth=1):
      self.ax = ax
      self.beg_coord = beg_coord
      self.end_coord = end_coord
      self.color = color
      self.linewidth = linewidth
            
      x1, y1 = [self.beg_coord[0],self.end_coord[0]], [self.beg_coord[1], self.end_coord[1]]
      ax.plot(x1, y1,color=self.color,linewidth=self.linewidth)

    def print_minmax(self, var, title):
        print(str(title) + "   min = " + str(np.nanmin(var)) + "  max = " + str(np.nanmax(var)))

    def set_minmaxText(self, ax, i, var, title, Lid_overlap, facconv):
      """
        Show min and max value Text in the plot
        If overlap variable, text is align to the right
        TODO : handle more than 2 overlap variables
      """    
      self.ax = ax
      self.var = var
      self.i = i
      self.title = title
      self.facconv = facconv
      
      strtext = "   min = " + "{:.3e}".format(np.nanmin(var*facconv)) + "  max = " + "{:.3e}".format(np.nanmax(var*facconv))
      if not Lid_overlap:
        self.ax[self.i].text(0.01, self.minmaxpad, strtext, verticalalignment='top', horizontalalignment='left',
          transform=self.ax[self.i].transAxes, color='black', fontsize=10)
      else:
        self.ax[self.i].text(self.lateralminmaxpad, self.minmaxpad, strtext, verticalalignment='top', horizontalalignment='right',
          transform=self.ax[self.i].transAxes, color='black', fontsize=10)    
      #  Print to help choose min/max value for ticks
      self.print_minmax(var*facconv, title)
      
    def showTimeText(self, ax, i, timetxt):
      """
        Show time validity
      """    
      self.ax = ax
      self.i = i
      self.timetxt = timetxt
      
      strtext = "Time = " + timetxt
      self.ax[self.i].text(0.0, self.timepad, strtext, verticalalignment='top', horizontalalignment='left',
          transform=self.ax[self.i].transAxes, color='black', fontsize=10)


    def psectionV(self, Lxx=[], Lzz=[], Lvar=[], Lxlab=[], Lylab=[], Ltitle=[], Lminval=[], Lmaxval=[], 
                 Lstep=[], Lstepticks=[], Lcolormap=[], Lcbarlabel=[], LcolorLine=[],
                 Lfacconv=[], ax=[], Lid_overlap=[], colorbar=True, orog=[], Lxlim=[], Lylim=[], Ltime=[], Lpltype=[], LaddWhite_cm=[]):
      """
        Horizontal cross section plot
        Arguments :
            - Lxx    : List of x or y coordinate variable or time axis
            - Lzz    : List of z coordinates variable
            - Lvar   : List of variables to plot
            - Lxlab  : List of x-axis label
            - Lylab  : List of y-axis label
            - Lxlim  : List of x (min, max) value plotted
            - Lylim  : List of y (min, max) value plotted
            - Ltime  : List of time (validity)
            - Ltitle : List of sub-title
            - Lminval: List of minimum value for each colorbar
            - Lmaxval: List of maximum value for each colorbar
            - Lstep  : List of color-steps for each colorbar
            - Lstepticks : List of value of labels for each colorbar
            - Lcolormap  : List of colormap
            - LcolorLine : List of colors for colors arg of contour (color line only)
            - Lcbarlabel : List of colorbar label legend (units)
            - Lfacconv   : List of factors for unit conversion of each variables
            - ax         : List of fig.axes for ploting multiple different types of plots in a subplot panel
            - Lid_overlap: List of number index of plot to overlap current variables
            - Lpltype      : List of types of plot 'cf' or 'c'. cf=contourf, c=contour (lines only)
            - colorbar   : show colorbar or not
            - LaddWhite_cm : List of boolean to add white color to a colormap at the first (low value) tick colorbar
      """
      self.ax = ax
      firstCall = (len(self.ax) == 0)
      
      # Initialize default value w.r.t to the number of plots
#      D={'Lxlab':Lxlab, 'Lylab':Lylab, 'Ltitle':Ltitle,'Lminval':Lminval, 'Lmaxval':Lmaxval, 
#         'Lstep':Lstep, 'Lstepticks':Lstepticks, 'Lcolormap':Lcolormap, 'Lcbarlabel':Lcbarlabel, 'Lfacconv':Lfacconv, 'Ltime':Ltime,
#         'LaddWhite_cm':LaddWhite_cm, 'Lpltype':Lpltype}
#      D = initialize_default_val(Lvar, D)

      #  Default values
      if not Lfacconv: Lfacconv = [1.0]*len(Lvar)
      if not Lcolormap and not LcolorLine: Lcolormap=['gist_rainbow_r']*len(Lvar) #  If no color given, a cmap is given
      if not Lcolormap: LcolorLine=['black']*len(Lvar)
      if not Lpltype: Lpltype=['cf']*len(Lvar)
      if not LaddWhite_cm: LaddWhite_cm=[False]*len(Lvar)
      if not Lylab: Lylab = ['']*len(Lvar)
      if not Lxlab: Lxlab = ['']*len(Lvar)    
      #  Add an extra percentage of the top max value for forcing the colorbar show the true user maximum value (correct a bug)
      Lmaxval = list(map(lambda x, y: x + 1E-6*y, Lmaxval, Lstep) ) #The extra value is 1E-6 times the step ticks of the colorbar
    
      #  On all variables to plot
      for i,var in enumerate(Lvar):
        if firstCall: #1st call
          iax = i
          self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1))
          self.nb_graph+=1
        elif Lid_overlap != []: #overlapping plot
          iax = Lid_overlap[i]
        else: #existing ax with no overlapping (graphd appended to existing panel)
          self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1))
          self.nb_graph+=1
          iax = len(self.ax)-1 #  The ax index of the new coming plot is the length of the existant ax -1 for indices matter
          
        #  Colors normalization
        norm = mpl.colors.Normalize(vmax=Lmaxval[i], vmin=Lminval[i])

        #  Print min/max (stout and on plot)
        self.set_minmaxText(self.ax, iax, var, Ltitle[i], Lid_overlap, Lfacconv[i])
        
        #  Print time validity
        if Ltime: self.showTimeText(self.ax, iax, str(Ltime[i]))
        
        # Number of contours level
        if not Lstep[i]: #  Default value of number of steps is 20
            Lstep[i] = (Lmaxval[i] - Lminval[i])/20  
            Lstepticks[i] = Lstep[i]
        
        levels_contour = np.arange(Lminval[i],Lmaxval[i],step=Lstep[i])
        
        #  Add White to colormap
        if LaddWhite_cm[i] and Lcolormap: Lcolormap[i]=self.addWhitecm(LaddWhite_cm[i], Lcolormap[i], len(levels_contour))
        
        #  Plot
        if Lpltype[i]=='c': #  Contour
            if LcolorLine:
                cf = self.ax[iax].contour(Lxx[i], Lzz[i], var*Lfacconv[i], levels=levels_contour, 
                                norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], colors=LcolorLine[i])
            else:
                cf = self.ax[iax].contour(Lxx[i], Lzz[i], var*Lfacconv[i], levels=levels_contour, 
                                norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], cmap=Lcolormap[i])                    
        else:  #  Contourf
          cf = self.ax[iax].contourf(Lxx[i], Lzz[i], var*Lfacconv[i], levels=levels_contour, 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], cmap=Lcolormap[i])            
   
        #  Title
        self.set_Title(self.ax, iax, Ltitle[i], Lid_overlap,Lxlab[i], Lylab[i])
    
        #  X/Y Axis label
        self.set_XYaxislab(self.ax, iax, Lxlab[i], Lylab[i])
        
        # X/Y Axis limits value
        if Lxlim:
          try:
            self.set_xlim(self.ax, iax, Lxlim[i])
          except:
             pass
        if Lylim:
          try:
            self.set_ylim(self.ax, iax, Lylim[i])
          except:
              pass
          
        #  Color label on contour-ligne
        if Lpltype[i]=='c': #  Contour
          self.ax[iax].clabel(cf, levels=np.arange(Lminval[i],Lmaxval[i],step=Lstep[i]))
        
        #Filling area under topography
        if not orog==[]:
          self.ax[iax].fill_between(Lxx[i][0,:], orog, color='black')
        
        #  Colorbar
        if colorbar:
          cb=plt.colorbar(cf, ax=self.ax[iax], fraction=0.031, pad=self.colorbarpad, ticks=np.arange(Lminval[i],Lmaxval[i],Lstepticks[i]), aspect=self.colorbaraspect)   
          cb.ax.set_title(Lcbarlabel[i], pad = self.labelcolorbarpad, loc='left') #This creates a new AxesSubplot only for the colorbar y=0 ==> location at the bottom
        
      return self.fig

    def pXY_lines(self, Lzz=[], Lvar=[], Lxlab=[], Lylab=[], Ltitle=[], Llinetype=[], Llinewidth=[],
                 Llinecolor=[], Llinelabel=[], Lfacconv=[], ax=[], id_overlap=None, Lxlim=[], 
                 Lylim=[], Ltime=[], LaxisColor=[]):
      """
        XY (multiple)-lines plot
        Arguments :
            - Lzz    : List of z coordinates variable [1D]
            - Lvar   : List of variables to plot [1D]
            - Lxlab  : List of x-axis label
            - Lylab  : List of y-axis label
            - Lxlim  : List of x (min, max) value plotted
            - Lylim  : List of y (min, max) value plotted
            - Ltime  : List of time (validity)
            - Ltitle : List of sub-title
            - Llinewidth : List of lines thickness
            - Llinetype  : List of line types
            - Lcolorlines: List of color lines
            - Llinelabel : List of legend label lines
            - Lfacconv   : List of factors for unit conversion of each variables
            - ax         : List of fig.axes for ploting multiple different types of plots in a subplot panel
            - Lid_overlap: List of number index of plot to overlap current variables
            - LaxisColor : List of colors for multiple x-axis overlap
      """
      self.ax = ax
      firstCall = (len(self.ax) == 0)
      #  Defaults value convert to x number of variables list
      if not Lfacconv:   Lfacconv = [1.0]*len(Lvar)
      if not Llinewidth: Llinewidth = [1.0]*len(Lvar)
      if not Llinecolor: Llinecolor = ['blue']*len(Lvar)
      if not Llinetype:  Llinetype = ['-']*len(Lvar)
      if not Llinelabel: Llinelabel = ['']*len(Lvar)
      if not LaxisColor: LaxisColor = ['black']*len(Lvar)
      if not Lylab: Lylab = ['']*len(Lvar)
      if not Lxlab: Lxlab = ['']*len(Lvar)
    
      if firstCall: #  1st call
        iax = 0
        self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,1, label='graph axe x down'))
        self.nb_graph+=1
      elif id_overlap: #  overlapping plot with a different x-axis
        self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph, label='graph axe x top',frame_on=False))
        iax = len(self.ax)-1
      else: #  existing ax with no overlapping (graph appended to existing panel)
        self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1))
        self.nb_graph+=1
        iax = len(self.ax)-1 #  The ax index of the new coming plot is the length of the existant ax -1 for indices matter
          
      #  On all variables to plot
      for i,var in enumerate(Lvar):
        #  Print time validity
        if Ltime: self.showTimeText(self.ax, iax, str(Ltime[i]))

        #  Plot
        cf = self.ax[iax].plot(var*Lfacconv[i], Lzz[i], color=Llinecolor[i], ls=Llinetype[i], 
                    label=Llinelabel[i], linewidth=Llinewidth[i])
        #  Legend
        #TODO : Handling legend with overlap two axis lines in the same box. For now, placement is by hand
        if not id_overlap: 
          self.ax[iax].legend(loc='upper right', bbox_to_anchor=(1, 0.95))
        else:
          self.ax[iax].legend(loc='upper right', bbox_to_anchor=(1, 0.90))

        #  Title
        if Ltitle: self.set_Title(self.ax, iax, Ltitle[i], id_overlap,Lxlab[i], Lylab[i])
    
        #  X/Y Axis label
        if id_overlap: 
          self.ax[iax].xaxis.tick_top()
          self.ax[iax].xaxis.set_label_position('top') 
          self.ax[iax].set_xlabel(Lxlab[i])
          self.ax[iax].set_ylabel(Lylab[i])
        else:
          self.set_XYaxislab(self.ax, iax, Lxlab[i], Lylab[i])
          
        self.ax[iax].tick_params(axis='x', colors=LaxisColor[i]) 

        # X/Y Axis limits value
        if Lxlim:
          try:
            self.set_xlim(self.ax, iax, Lxlim[i])
          except:
             pass
        if Lylim:
          try:
            self.set_ylim(self.ax, iax, Lylim[i])
          except:
              pass
      return self.fig
    
    def psectionH(self, lon=[],lat=[], Lvar=[], Lcarte=[], Llevel=[], Lxlab=[], Lylab=[], Ltitle=[], Lminval=[], Lmaxval=[], 
                 Lstep=[], Lstepticks=[], Lcolormap=[], LcolorLine=[], Lcbarlabel=[], Lproj=[], Lfacconv=[], coastLines=True, ax=[], 
                 Lid_overlap=[], colorbar=True, Ltime=[], LaddWhite_cm=[], Lpltype=[]):
      """
        Horizontal cross section plot
        Arguments :
            - lon    : longitude 2D array
            - lat    : latitude 2D array
            - Lvar   : List of variables to plot
            - Lcarte : Zooming [lonmin, lonmax, latmin, latmax]
            - Llevel : List of k-level value for the section plot (ignored if variable is already 2D)
            - Lxlab  : List of x-axis label
            - Lylab  : List of y-axis label
            - Ltitle : List of sub-title
            - Ltime  : List of time (validity)
            - Lminval: List of minimum value for each colorbar
            - Lmaxval: List of maximum value for each colorbar
            - Lstep  : List of color-steps for each colorbar
            - Lstepticks : List of value of labels for each colorbar
            - Lcolormap  : List of colormap
            - LcolorLine : List of colors for colors arg of contour (color line only)
            - Lcbarlabel : List of colorbar label legend (units)
            - Lproj      : List of ccrs cartopy projection ([] for cartesian coordinates)
            - Lfacconv   : List of factors for unit conversion of each variables
            - coastLines : Boolean to plot coast lines and grid lines
            - ax         : List of fig.axes for ploting multiple different types of plots in a subplot panel
            - Lid_overlap : List of number index of plot to overlap current variables
            - colorbar   : show colorbar or not
            - Lpltype      : List of types of plot 'cf' or 'c'. cf=contourf, c=contour (lines only)
            - LaddWhite_cm : List of boolean to add white color to a colormap at the first (low value) tick colorbar
      """
      self.ax = ax
      firstCall = (len(self.ax) == 0)
      
      # Initialize default value w.r.t to the number of plots
#      D={'lon':lon, 'lat':lat, 'Lcarte':Lcarte, 'Llevel':Llevel, 'Lxlab':Lxlab, 'Lylab':Lylab, 'Ltitle':Ltitle,'Lminval':Lminval, 'Lmaxval':Lmaxval, 
#         'Lstep':Lstep, 'Lstepticks':Lstepticks, 'Lcolormap':Lcolormap, 'Lcbarlabel':Lcbarlabel, 'Lproj':Lproj, 'Lfacconv':Lfacconv, 'Ltime':Ltime,
#         'LaddWhite_cm':LaddWhite_cm, 'Lpltype':Lpltype}
#      D = initialize_default_val(Lvar, D)
      
      #  If all plots are not using conversion factor, convert it to List
      if not Lfacconv: Lfacconv = [1.0]*len(Lvar)
      if not Lylab: Lylab = ['']*len(Lvar)
      if not Lxlab: Lxlab = ['']*len(Lvar)
      if not Lcolormap and not LcolorLine: Lcolormap=['gist_rainbow_r']*len(Lvar) #  If no color given, a cmap is given
      if not Lcolormap: LcolorLine=['black']*len(Lvar)
      if not Lpltype: Lpltype=['cf']*len(Lvar)
      if not LaddWhite_cm: LaddWhite_cm=[False]*len(Lvar)
      #  Add an extra percentage of the top max value for forcing the colorbar show the true user maximum value (correct a bug)
      if Lstep: Lmaxval = list(map(lambda x, y: x + 1E-6*y, Lmaxval, Lstep) ) #The extra value is 1E-6 times the step ticks of the colorbar
    
      #  This following must be after the extra percentage top value addition
      if not Lstep: Lstep=[None]*len(Lvar)
      if not Lstepticks: Lstepticks=[None]*len(Lvar)

      #  On all variables to plot
      for i,var in enumerate(Lvar):
        if firstCall: #1st call
          iax = i
          if Lproj:
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1, projection = Lproj[i]))
          else: # Cartesian coordinates
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1))
          self.nb_graph+=1
        elif Lid_overlap != []: #overlapping plot
          iax = Lid_overlap[i]
        else: #existing ax with no overlapping (graphd appended to existing panel)
          if Lproj:
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1, projection = Lproj[i]))
          else: # Cartesian coordinates
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1))
          self.nb_graph+=1
          iax = len(self.ax)-1 #  The ax index of the new coming plot is the length of the existant ax -1 for indices matter

        #Colors normalization
        norm = mpl.colors.Normalize(vmax=Lmaxval[i], vmin=Lminval[i])
        
        #  Zooming
        if len(Lcarte) == 4: #zoom
          self.ax[iax].set_xlim(Lcarte[0], Lcarte[1])
          self.ax[iax].set_ylim(Lcarte[2], Lcarte[3])
        #  Variable to plot w.r.t dimensions
        if var.ndim==2:
          vartoPlot = var[:,:]
        else:
          vartoPlot = var[Llevel[i],:,:]
    
        #  Print min/max (stout and on plot)
        self.set_minmaxText(self.ax, iax, vartoPlot, Ltitle[i], Lid_overlap, Lfacconv[i])
        
        #  Print time validity
        if Ltime: self.showTimeText(self.ax, iax, str(Ltime[i]))
        
        # Number of contours level
        if not Lstep[i]: #  Default value of number of steps is 20
            Lstep[i] = (Lmaxval[i] - Lminval[i])/20  
            Lstepticks[i] = Lstep[i]
        
        levels_contour = np.arange(Lminval[i],Lmaxval[i],step=Lstep[i])
        
        #  Add White to colormap
        if LaddWhite_cm[i] and Lcolormap: Lcolormap[i]=self.addWhitecm(LaddWhite_cm[i], Lcolormap[i], len(levels_contour))

        #  Plot
        if Lproj:
          if Lpltype[i]=='c': #  Contour
              if LcolorLine:
                  cf = self.ax[iax].contourf(lon[i], lat[i], vartoPlot*Lfacconv[i], levels=levels_contour,transform=Lproj[i], 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], colors=LcolorLine[i])
              else:
                  cf = self.ax[iax].contourf(lon[i], lat[i], vartoPlot*Lfacconv[i], levels=levels_contour,transform=Lproj[i], 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], cmap=Lcolormap[i])
          else:
            cf = self.ax[iax].contourf(lon[i], lat[i], vartoPlot*Lfacconv[i], levels=levels_contour,transform=Lproj[i], 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], cmap=Lcolormap[i])
        else: # Cartesian coordinates
          if Lpltype[i]=='c': #  Contour
            cf = self.ax[iax].contourf(lon[i], lat[i], vartoPlot*Lfacconv[i], levels=levels_contour, 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], colors=LcolorLine[i])
          else:
            cf = self.ax[iax].contourf(lon[i], lat[i], vartoPlot*Lfacconv[i], levels=levels_contour, 
                         norm=norm, vmin=Lminval[i], vmax=Lmaxval[i], cmap=Lcolormap[i])
        #  Title
        self.set_Title(self.ax, iax, Ltitle[i], Lid_overlap,Lxlab[i], Lylab[i])
        
        #  Coastlines / Grid lines and labels
        if Lproj: self.draw_Backmap(coastLines, self.ax[iax], Lproj[i])
    
        #  X/Y Axis
        self.set_XYaxislab(self.ax, iax, Lxlab[i], Lylab[i])
        
        #  Color label on contour-ligne
        if Lpltype[i]=='c': #  Contour
          self.ax[iax].clabel(cf, levels=np.arange(Lminval[i],Lmaxval[i],step=Lstep[i]))
        
        #  Colorbar
        if colorbar:
          cb=plt.colorbar(cf, ax=self.ax[iax], fraction=0.031, pad=self.colorbarpad, ticks=np.arange(Lminval[i],Lmaxval[i],Lstepticks[i]), aspect=self.colorbaraspect)   
          cb.ax.set_title(Lcbarlabel[i], pad = self.labelcolorbarpad, loc='left') #This creates a new AxesSubplot only for the colorbar y=0 ==> location at the bottom
        
      return self.fig
    
    
    def pvector(self, Lxx=[], Lyy=[], Lvar1=[], Lvar2=[], Lcarte=[], Llevel=[], Lxlab=[], Lylab=[], 
                Ltitle=[], Lwidth=[], Larrowstep=[], Lcolor=[], Llegendval=[], Lcbarlabel=[], 
                Lproj=[], Lfacconv=[], ax=[], coastLines=True, Lid_overlap=[], Ltime=[], Lscale=[],
                Lylim=[], Lxlim=[]):
      """
        Horizontal vectors lines
        Arguments :
            - Lxx    : List of x or y coordinate variable (lat or ni or nm)
            - Lyy    : List of y coordinates variable (lon or level)
            - Lvar1   : List of wind-component along x/y or oblic axis (3D for hor. section, 2D for vertical section)
            - Lvar2   : List of wind-component along y-axis : v-component for horizontal section / w-component for vertical section
            - Lcarte : Zooming [lonmin, lonmax, latmin, latmax]
            - Llevel : List of k-level value for the horizontal section plot (ignored if variable is already 2D)
            - Lxlab  : List of x-axis label
            - Lylab  : List of y-axis label
            - Lxlim  : List of x (min, max) value plotted
            - Lylim  : List of y (min, max) value plotted
            - Ltitle : List of sub-titles
            - Ltime  : List of time (validity)
            - Lwidth : List of thickness of the arrows
            - Lscale : List of scale for the length of the arrows (high value <=> small length)
            - Larrowstep : List of sub-sample (frequency) if too much arrows
            - Lcolor : List of colors for the arrows (default: black)
            - Llegendval : List of value for the legend of the default arrow
            - Lcbarlabel : List of labels for the legend of the default arrow
            - Lproj      : List of ccrs cartopy projection
            - Lfacconv   : List of factors for unit conversion of each variables
            - coastLines : Boolean to plot coast lines and grid lines
            - ax         : List of fig.axes for ploting multiple different types of plots in a subplot panel
            - Lid_overlap : List of number index of plot to overlap current variables
      """
      self.ax = ax
      firstCall = (len(self.ax) == 0)
      # If all plots are not using conversion factor, convert it to List
      if not Lfacconv:  Lfacconv = [1.0]*len(Lvar1)
      if not Lcolor: Lcolor = ['black']*len(Lvar1)
      if not Lscale : Lscale = [None]*len(Lvar1)
      if not Lylab: Lylab = ['']*len(Lvar1)
      if not Lxlab: Lxlab = ['']*len(Lvar1)
      #  On all variables to plot
      for i,var1 in enumerate(Lvar1):
        if firstCall: #1st call
          iax = i
          if Lproj: 
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1, projection = Lproj[i]))
          else:
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1))
          self.nb_graph+=1
        elif Lid_overlap != []: #overlapping plot
          iax = Lid_overlap[i]
        else: #existing ax with no overlapping (graphd appended to existing panel)
          if Lproj:  
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1, projection = Lproj[i]))
          else:
            self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1))
          self.nb_graph+=1
          iax = len(self.ax)-1 #  The ax index of the new coming plot is the length of the existant ax -1 for indices matter
          
        #  Zooming
        if len(Lcarte) == 4: #zoom
          self.ax[iax].set_xlim(Lcarte[0], Lcarte[1])
          self.ax[iax].set_ylim(Lcarte[2], Lcarte[3])
        
        #  Variable to plot w.r.t dimensions
        if var1.ndim==2:
          vartoPlot1 = var1[:,:]
          vartoPlot2 = Lvar2[i][:,:]
        else: #  Variable is 3D : only for horizontal section
          vartoPlot1 = var1[Llevel[i],:,:]
          vartoPlot2 = Lvar2[i][Llevel[i],:,:]
        
        #  Print min/max val to help choose colorbar steps
        self.set_minmaxText(self.ax, iax, np.sqrt(vartoPlot1**2 + vartoPlot2**2), Ltitle[i], Lid_overlap, Lfacconv[i])
        
        #  Print time validity
        if Ltime: self.showTimeText(self.ax, iax, str(Ltime[i]))

        #  Plot
        axeX = Lxx[i]
        axeY = Lyy[i]
        if Lxx[i].ndim == 2:
          cf = self.ax[iax].quiver(axeX[::Larrowstep[i],::Larrowstep[i]], axeY[::Larrowstep[i],::Larrowstep[i]], 
                       vartoPlot1[::Larrowstep[i],::Larrowstep[i]], vartoPlot2[::Larrowstep[i],::Larrowstep[i]],
                       width=Lwidth[i] ,angles='uv', color=Lcolor[i],scale=Lscale[i])
        else:
          cf = self.ax[iax].quiver(axeX[::Larrowstep[i]], axeY[::Larrowstep[i]], 
                       vartoPlot1[::Larrowstep[i],::Larrowstep[i]], vartoPlot2[::Larrowstep[i],::Larrowstep[i]],
                       width=Lwidth[i] ,angles='uv', color=Lcolor[i], scale=Lscale[i]) 
        #  Title
        self.set_Title(self.ax, iax, Ltitle[i], Lid_overlap,Lxlab[i], Lylab[i])

        #  X/Y Axis Label
        self.set_XYaxislab(self.ax, iax, Lxlab[i], Lylab[i])
        
        # X/Y Axis limits value
        if Lxlim:
          try:
            self.set_xlim(self.ax, iax, Lxlim[i])
          except:
             pass
        if Lylim:
          try:
            self.set_ylim(self.ax, iax, Lylim[i])
          except:
              pass
        
        #  Coastlines:
        if Lproj: self.draw_Backmap(coastLines, self.ax[iax], Lproj[i])
    
        # Arrow legend key
        qk = self.ax[iax].quiverkey(cf, 1.0, -0.05, Llegendval[i], str(Llegendval[i]) + Lcbarlabel[i], labelpos='E', color='black')
           
      return self.fig

    def pXY_bar(self, Lbins=[], Lvar=[], Lxlab=[], Lylab=[], Ltitle=[], Lcolor=[], Lwidth=[],
                 Llinecolor=[], Llinewidth=[], Lfacconv=[], ax=[], id_overlap=None, Lxlim=[], 
                 Lylim=[], Ltime=[], LaxisColor=[]):
      """
        XY Histogram
        Arguments :
            - Lbins    : List of bins
            - Lvar   : List of the value for each bin
            - Lxlab  : List of x-axis label
            - Lylab  : List of y-axis label
            - Ltitle : List of sub-title
            - Lcolor : List of color (or sequence of colors for each value) of the bars
            - Lwidth     : List of width of the bars
            - Llinecolor  : List of line color of the bar edges
            - Llinewidth  : List of lines thickness of the bar edges
            - Lfacconv   : List of factors for unit conversion of each variables
            - Lxlim  : List of x (min, max) value plotted
            - Lylim  : List of y (min, max) value plotted
            - Ltime  : List of time (validity)
            - ax         : List of fig.axes for ploting multiple different types of plots in a subplot panel
            - Lid_overlap: List of number index of plot to overlap current variables
            - LaxisColor : List of colors for multiple x-axis overlap
      """
      self.ax = ax
      firstCall = (len(self.ax) == 0)
      #  Defaults value convert to x number of variables list
      if not Lfacconv: Lfacconv = [1.0]*len(Lvar)
      if not LaxisColor: LaxisColor = ['black']*len(Lvar)
      if not Lylab: Lylab = ['']*len(Lvar)
      if not Lxlab: Lxlab = ['']*len(Lvar)
      if not Lcolor: Lcolor = ['black']*len(Lvar)
      if not Lwidth: Lwidth = [1]*len(Lvar)
      if not Llinecolor: Llinecolor = ['black']*len(Lvar)
      if not Llinewidth: Llinewidth = [0]*len(Lvar)
             
      #  On all variables to plot
      for i,var in enumerate(Lvar):
        if firstCall: #  1st call
          iax = i
          self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,i+1, label='graph axe x down'))
          self.nb_graph+=1
        elif id_overlap: #  overlapping plot with a different x-axis
          self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph, label='graph axe x top',frame_on=False))
          iax = len(self.ax)-1
        else: #  existing ax with no overlapping (graph appended to existing panel)
          self.ax.append(self.fig.add_subplot(self.nb_l,self.nb_c,self.nb_graph+1))
          self.nb_graph+=1
          print(len(self.ax))
          iax = len(self.ax)-1 #  The ax index of the new coming plot is the length of the existant ax -1 for indices matter
       
        #  Print time validity
        if Ltime: self.showTimeText(self.ax, iax, str(Ltime[i]))

        #  Bins by labels
        labels = np.array([str(L) for L in Lbins[i]])

        #  Plot
        cf = self.ax[iax].bar(labels, var*Lfacconv[i], width=Lwidth[i], color=Lcolor[i], linewidth=Llinewidth[i], edgecolor=Llinecolor[i])        
               
        #  Legend
        #TODO : Handling legend with overlap two axis lines in the same box. For now, placement is by hand
        if not id_overlap: 
          self.ax[iax].legend(loc='upper right', bbox_to_anchor=(1, 0.95))
        else:
          self.ax[iax].legend(loc='upper right', bbox_to_anchor=(1, 0.90))

        #  Title
        if Ltitle: self.set_Title(self.ax, iax, Ltitle[i], id_overlap,Lxlab[i], Lylab[i])
    
        #  X/Y Axis label
        if id_overlap: 
          self.ax[iax].xaxis.tick_top()
          self.ax[iax].xaxis.set_label_position('top') 
          self.ax[iax].set_xlabel(Lxlab[i])
          self.ax[iax].set_ylabel(Lylab[i])
        else:
          self.set_XYaxislab(self.ax, iax, Lxlab[i], Lylab[i])
          
        self.ax[iax].tick_params(axis='x', colors=LaxisColor[i]) 

        # X/Y Axis limits value
        if Lxlim:
          try:
            self.set_xlim(self.ax, iax, Lxlim[i])
          except:
             pass
        if Lylim:
          try:
            self.set_ylim(self.ax, iax, Lylim[i])
          except:
              pass

      return self.fig
#def initialize_default_val(Lvar, Dparam):
#    #TODO : initialize default value for all parameter of all type of graphs
#    #Returns All the parameters given in Dparam where :
#    "- If no value is found (empty list []) : return the default value (if exist) * number of graph
#    #- If ONE value only is found : return the value copied x times the number of graph
#    #- If the list is complete, nothing is done
#    #CURRENT PROBLEM
#    #The returned value do not change the true referenced variable given as argument        
#    #  Number of graphs
#    l = len(Lvar)
#    
#    #  Add an extra percentage of the top max value for forcing the colorbar show the true user maximum value (correct a bug)
#    #if Dparam['Lstep'] and Dparam['Lmaxval']: Dparam['Lmaxval'] = list(map(lambda x, y: x + 1E-6*y, Dparam['Lmaxval'], Dparam['Lstep']) ) #The extra value is 1E-6 times the step ticks of the colorbar
#    print(Dparam.items())
#    
#    #  Read on which parameters initialize the default values
#    for args_t in list(Dparam.items()):  #  Test on all arguments present, if they are empty list, default values apply for each graph
#      args = list(args_t)
#      print(args)
#      if args[0] == 'Lfacconv' and not args[1]: args[1] = [1.0]*l
#      elif args[0] == 'Lcolormap' and not args[1]: args[1] = ['gist_rainbow_r']*l
#      elif args[0] == 'LcolorLine' and not args[1]: args[1] = ['black']*l
#      elif args[0] == 'Lpltype' and not args[1]: args[1]= ['cf']*l
#      elif args[0] == 'LaddWhite_cm' and not args[1]: args[1] = ['False']*l
#      elif args[0] == 'Lstep' and not args[1]: args[1] = [None]*l #  default value filled later
#      elif args[0] == 'Lstepticks' and not args[1]: args[1] = [None]*l
#      Dparam[args[0]] = args[1]
#      print(args)
#     
#    #  Check if there is no value for a parameter
##    for args_t in list(Dparam.items()):
##      args = list(args_t)
##      if args[1]
#    #  Number of contours level
##    for i in range(l):
##      if 'Lstepticks' in arguments.args and 'Lmaxval' in arguments.args and 'Lminval' in arguments.args: 
##        Lstep[i] = (Lmaxval[i] - Lminval[i])/20  #  Default value of number of steps is 20
##        Lstepticks[i] = Lstep[i]  #  Default value is stepticks are the same as steps values
#
#        
#    return Dparam