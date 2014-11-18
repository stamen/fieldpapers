#include <Python.h>
#include <string.h>
#include <stdio.h>
#include <set>
#include <map>
#include <vector>
using namespace std;

/* blobs.detect()
 *
 *  Given image dimensions and a raw string of grayscale pixels, detects blobs
 *  in the "image" Uses two-pass connected component algorithm described here:
 *  http://en.wikipedia.org/wiki/Blob_extraction#Two-pass (Jan 2011).
 */
static PyObject *detect(PyObject *self, PyObject *args)
{
    int x, y, w, h, off, len, label, blobs = 0;
    unsigned char *pixels;
    map< int, set<int> > groups;
    
    if(!PyArg_ParseTuple(args, "iis#", &w, &h, &pixels, &len))
    {
        /* fail unless I got two ints and a single string as input */
        return NULL;
    }
    
    if(w * h != len)
    {
        // fail if the given dimensions don't seem to match the passed image
        return NULL;
    }
    
   /*
    * Pass one: provisionally label each non-background cell with a label.
    */
    
    // an array to hold the labels
    int labels[w * h];
    set<int> groupset;
    set<int>::iterator groupiter;
    
    for(y = 0; y < h; y++)
    {
        for(x = 0; x < w; x++)
        {
            // offset in the string for a given (x, y) pixel
            off = (y * w) + x;
            
            if(pixels[off] < 0x80)
            {
                // dark pixel means it's part of the background
                labels[off] = 0;

            } else {
                // light pixel means it's part of a blob
                
                if(y > 0 && labels[off - w] > 0 && x > 0 && labels[off - 1] > 0) {
                    // pixels up and left are both known blobs
                    label = labels[off - w];
                    
                    if(label != labels[off - 1])
                    {
                        // associate the two labels
                        groups[label].insert(labels[off - 1]);
                        groups[labels[off - 1]].insert(label);
                        
                        // unify the sets - make sure they all have the same items

                        groupset = groups[label];
                        
                        for(groupiter = groupset.begin(); groupiter != groupset.end(); groupiter++)
                        {
                            groups[labels[off - 1]].insert(*groupiter);
                        }
                        
                        groupset = groups[labels[off - 1]];
                        
                        for(groupiter = groupset.begin(); groupiter != groupset.end(); groupiter++)
                        {
                            groups[label].insert(*groupiter);
                        }
                    }

                } else if(y > 0 && labels[off - w] > 0) {
                    // pixel one row up is a known blob
                    label = labels[off - w];
                
                } else if(x > 0 && labels[off - 1] > 0) {
                    // pixel to the left is a known blob
                    label = labels[off - 1];
                
                } else {
                    // a new blob!
                    blobs++;
                    label = blobs;
                    
                    groups[label] = set<int>();
                    groups[label].insert(label);
                }
                
                labels[off] = label;
            }
        }
    }
    
   /*
    * Pass two: merge labels of connected components, collect bboxes along the way.
    */
    
    map< int, vector<int> > bounds;
    
    for(y = 0; y < h; y++)
    {
        for(x = 0; x < w; x++)
        {
            // offset in the string for a given (x, y) pixel
            off = (y * w) + x;
            
            if(labels[off] > 0)
            {
                label = *(groups[labels[off]].begin());
                
                if(bounds.find(label) == bounds.end())
                {
                    bounds[label] = vector<int>(5);
                    
                    bounds[label][0] = x;
                    bounds[label][1] = y;
                    bounds[label][2] = x;
                    bounds[label][3] = y;
                    bounds[label][4] = 1;

                } else {
                    bounds[label][0] = min(x, bounds[label][0]);
                    bounds[label][1] = min(y, bounds[label][1]);
                    bounds[label][2] = max(x, bounds[label][2]);
                    bounds[label][3] = max(y, bounds[label][3]);
                    bounds[label][4] += 1;
                }
            }
        }
    }

   /*
    * Build python response.
    */
    
    map< int, vector<int> >::iterator bounditer;
    uint32_t response[5 * bounds.size()];
    vector<int> bbox;
    off = 0;

    for(bounditer = bounds.begin(); bounditer != bounds.end(); bounditer++)
    {
        bbox = (*bounditer).second;
    
        response[off + 0] = bbox[0];
        response[off + 1] = bbox[1];
        response[off + 2] = bbox[2];
        response[off + 3] = bbox[3];
        response[off + 4] = bbox[4];
        
        off += 5;
    }
    
    return Py_BuildValue("is#", bounds.size(), response, bounds.size() * sizeof(uint32_t) * 5);
}

/* map between python function name and C function pointer */
static PyMethodDef BlobsMethods[] = {
    {"detect", detect, METH_VARARGS, "Detect blobs in an image. Arguments are width, height, and image string.\nReturns list of bbox tuples (left, top, right, bottom), one for each blob."},
    {NULL, NULL, 0, NULL}
};

/* bootstrap function, called automatically when you 'import _blobs' */
PyMODINIT_FUNC init_blobs(void) {
    (void)Py_InitModule("_blobs", BlobsMethods);
}
