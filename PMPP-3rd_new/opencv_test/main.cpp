#include <cv.h>
#include <highgui.h>
 
int main(int argc, char** argv )
{
 IplImage* img = cvLoadImage("nexus.jpg");
 cvNamedWindow("Image",CV_WINDOW_AUTOSIZE);
 cvShowImage( "Image",img);
 int key = cvWaitKey(0);
 
 cvDestroyWindow( "Image" );
 cvReleaseImage(&img);
}
