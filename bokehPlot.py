import numpy as np
import csv
import pandas as pd
from bokeh.plotting import *
from bokeh.models import HoverTool, ColumnDataSource, LinearColorMapper,ColorBar
import scipy.io
from scipy.io import loadmat
import matplotlib as plt
import matplotlib.cm as cm



#
########## Load data ##########
#
data_path = '/home/jovyan/work'
node_file = data_path + '/Scan_names.csv' # 1 column of node names - header = "name"



nodes = pd.read_csv(node_file)


nodes['name'] = [str(x) for x in nodes['name']]
names = list(nodes['name'])

mat = loadmat('/home/jovyan/work/CorrelationMatrices.mat')

cormat = np.array(mat['scanCorMatrix_wm']);
cormat = np.squeeze(cormat);
shp = np.shape(cormat)
sz = shp[1]


#
########## Manipulate data into appropriate format ##########
#
n1 = []
n2 = []
color = []
weight = []
alpha = []
for node1 in range(0,sz):
    for node2 in range(0,sz):
        n1.append(names[node1])
        # n2.append(str(node1) + " " + names[node2])
        n2.append(names[node2])
        value = cormat[node1][node2]
        weight.append(value)
        alpha.append(1)

        
        #color.append(links_csv[node1,node2])
        

# create a `ColumnDataSource` with columns: month, year, color, rate
source = ColumnDataSource(data=dict(
        xname=n1,
        yname=n2,
        #color=color,
        weight=weight,
        alpha=alpha,
        count=cormat.flatten()
    )
)
########## Output ##########

colormap =cm.get_cmap("jet") 
bokehpalette = [plt.colors.rgb2hex(m) for m in colormap(np.arange(colormap.N))]

color_mapper = LinearColorMapper(palette=bokehpalette, low=min(cormat.flatten()), high=max(cormat.flatten()))
color_bar = ColorBar(color_mapper=color_mapper, label_standoff=12, border_line_color=None, location=(2,0))

p = figure(title="Correlation Matrix",
           x_axis_location="above", tools="hover,save",
           x_range=list(reversed(names)), y_range=names)


p.plot_width = 450
p.plot_height = 450
p.grid.grid_line_color = None
p.axis.axis_line_color = None
p.axis.major_tick_line_color = None
p.axis.major_label_text_font_size = "10pt"
p.axis.major_label_standoff = 0
p.xaxis.major_label_orientation = np.pi/3


p.add_layout(color_bar, 'right')
p.rect('xname', 'yname', 0.9, 0.9, source=source, alpha='alpha', line_color=None,
hover_line_color='black',color={'field': 'count', 'transform': color_mapper})

p.select_one(HoverTool).tooltips = [
    ('Pair', '@yname, @xname'),
    ('r', '@count'),
]

p.toolbar.logo = None
p.toolbar_location = None

output_file("correlation.html", title="Correlation Matix")
output_notebook()

show(p) # show the plot



