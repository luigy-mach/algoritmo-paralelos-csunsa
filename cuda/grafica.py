from bokeh.plotting import figure, output_file, show
import csv


with open('data1.csv', 'rb') as f:
    reader = csv.reader(f)

	#x = [1, 23, 33, 42, 52]
	#y = [6, 7, 8, 7, 3]
    x1=[]
    y1=[]
    x2=[]
    y2=[]
  

    for row in reader:
        x1.append(row[0])
        y1.append(row[1])
        x2.append(row[0])
        y2.append(row[2])
     
    print x1
    print y1


output_file("grafica.html")

p = figure(plot_width=500, plot_height=400)



p.line(x1, y1, line_width=2,legend="tile 32", line_color="blue")
p.circle(x1, y1, legend="tile 32",fill_color=None, line_color="blue")

p.line(x2, y2, line_width=2,legend="sin memoria compartida", line_color="red")
p.circle(x2, y2, legend="sin memoria compartida",fill_color=None, line_color="red")




p.legend.location = "bottom_right"
p.legend.background_fill_color = "white"
p.legend.background_fill_alpha = 0.5

#p.legend.label_standoff = 10
#p.legend.glyph_width = 20
#p.legend.spacing = 10
#p.legend.margin = 20
#p.legend.padding = 10


show(p)
#save(p,"xx.html")
