#!/usr/bin/env python
# vim: set ft=python

# R logo created by Tobias Wolf <towolf@gmail.com> (cc-by-ca)
# see https://stat.ethz.ch/pipermail/r-devel/2010-October/058791.html

# svgutils (https://github.com/btel/svg_utils)
# https://raw.github.com/btel/svg_utils/be33caff2e53b9069cbaf7f2a1d0bf56212b3517/src/svgutils/transform.py
import transform

# create new SVG figure
fig = transform.SVGFigure("16.25cm", "9.4cm")

fig_1 = transform.fromfile("map.svg")
fig_2 = transform.fromfile("svg/R.svg")

# get plot objects
plot_1 = fig_1.getroot()
plot_2 = fig_2.getroot()
plot_2.moveto(170, 15, scale=0.50)
txt = transform.TextElement(65, 70, "Vienna", size=40,
                            weight="bold", font="Verdana")

# append plots and labels to figure
fig.append([plot_1, plot_2, txt])
# save generated SVG files
fig.save("result_1.svg")

#####

# create new SVG figure
fig = transform.SVGFigure("16.25cm", "9.4cm")

fig_1 = transform.fromfile('map.svg')
fig_2 = transform.fromfile('svg/R_simple.svg')

# get plot objects
plot_1 = fig_1.getroot()
plot_2 = fig_2.getroot()
plot_2.moveto(170, 15, scale=3.6)
txt = transform.TextElement(65, 70, "Vienna", size=40,
                            weight="bold", font="Verdana")

# append plots and labels to figure
fig.append([plot_1, plot_2, txt])
# save generated SVG files
fig.save("result_2.svg")
