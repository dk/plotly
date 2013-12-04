#!/usr/bin/env perl
#
# Mandelbrot generation function is courtesy of Xavier Calbet
# from http://www.freesoftwaremagazine.com/articles/cool_fractals_with_perl_pdl_a_benchmark
#
# see result at https://plot.ly/~karasik.dmitry/2/

use strict;
use warnings;
use PDL; 
use WebService::Plotly;

open F, 'key';
my $key = <F>;
chomp $key;

my $plotly = WebService::Plotly->new( un => 'karasik.dmitry', key => $key );

# Number of points in side of image and
# number of iterations in the Mandelbrot
# fractal calculation
my $npts=512;
my $niter=25;

my ($x1,$x2) = (-1.5, 0.5);
my ($y1,$y2) = (-1, 1);

# Generating z = 0 (real and
# imaginary part)
my $zRe=zeroes(double,$npts,$npts);
my $zIm=zeroes(double,$npts,$npts);

# Generating the constant k (real and
# imaginary part)
my $kRe=$zRe->xlinvals($x1,$x2);
my $kIm=$zIm->ylinvals($y1,$y2);
	
# Iterating 
for(my $j=0;$j<$niter;$j++){
    # Calculating q = z*z + k in complex space
    # q is a temporary variable to store the result
    my $qRe=$zRe*$zRe-$zIm*$zIm+$kRe;
    my $qIm=2*$zRe*$zIm+$kIm;
    # Assigning the q values to z constraining between
    # -5 and 5 to avoid numerical divergences
    $zRe=$qRe->clip(-5,5);
    $zIm=$qIm->clip(-5,5);
}

# Generating the image to plot
my ($dmin, $dmax) = (1,254);
my $image = log( sqrt($zRe**2+$zIm**2) + 1);
my $min = $image->minimum->minimum;
my $max = $image->maximum->maximum;
$image = ( $image * ($dmax - $dmin) + $dmin * $max - $dmax * $min ) / ($max - $min);

# plot
my $response = $plotly->plot({
	z => $image->byte->unpdl,
	type => 'heatmap',
});
  
print "url is:\n\t$response->{url}\n\n";
print "filename on our server is: \n\t$response->{filename}\n";
