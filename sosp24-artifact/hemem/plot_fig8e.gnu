set terminal postscript eps enhanced size 7,3 defaultplex leveldefault color colortext dashlength 1.0 linewidth 2.0 pointscale 2.5 butt noclip nobackground palfuncparam 2000,0.003 "Helvetica" 25 fontscale 1.4

set encoding utf8
set grid ytics lt 0 lw 4 lc rgb "#bbbbbb"
set grid xtics lt 0 lw 4 lc rgb "#bbbbbb"
set style fill transparent solid 0.7 border -1
#set bmargin 4
#set rmargin 7.85
set tmargin 2.5
set rmargin 1.1
set lmargin 8

set key outside center top
# set key at screen 0.5, 1
set key vertical maxrows 1
# set key width -1

#set ytics 0,0.1,1.5
# set yrange [0:200]
# set xtics 0,4,16

# set yrange [0:80]
# set xrange [50:150]
# set xtics 50,25,150
# set ytics 0,20,80

set ylabel "Throughput (Mops/sec)" font "Helvetica, 25"
set xlabel 'Time (secs)' font "Helvetica, 25"

set xrange [0:70]
set yrange [0:5]
set output '~/colloid-eval/fig8e.eps'
plot '~/colloid-eval/fig8e-hemem.tsv' using ($0/10-172):($1*10/1e6) w l lw 5 lc rgb '#fa9819' t 'HeMem', '~/colloid-eval/fig8e-hemem-colloid.tsv' using ($0/10-172):($1*10/1e6) w l lw 5 dt 6 lc rgb '#029AE3' t 'HeMem+colloid'