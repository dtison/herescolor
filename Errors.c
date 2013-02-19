
/*  This is just an embodiment framework for the actual error messages.  TODO:
    put this table in init and load from English.lproj...  */

#import "/LocalLibrary/HERELibrary/Include/HEREerrors.h"

ErrorStruct errorTable[] = {
{Err_UserAbandon, ""},
{Err_FileOpenError, "Unable to open file."},
{Err_FileReadError, "A problem occurred reading from file."},
{Err_FileWriteError, "There was a problem writing to disk.  See if your hard drive is out of space.  Or, you may not have write permission for the file."},
{Err_MemoryAllocationError, "Can't allocate enough memory.  See if your swapfile drive is out of space"},
{Err_InternalError, "An internal error occurred"},
{Err_TransformError0, "Internal Transform Error (0)"},
{Err_TransformError1, "Internal Transform Error (1)"},
{Err_TransformError2, "Internal Transform Error (2)"},
{Err_TransformError3, "Internal Transform Error (3)"},
{Err_TransformError4, "Internal Transform Error (4)"},
{Err_TransformError5, "Internal Transform Error (5)"},
{Err_TransformError6, "Internal Transform Error (6)"},
{Err_TransformError7, "Internal Transform Error (7)"},
{Err_TransformError8, "Internal Transform Error (8)"},
{Err_TransformError9, "Internal Transform Error (9)"},
{Err_TransformError10, "Internal Transform Error (10)"},
{Err_TransformError11, "Internal Transform Error (11)"},
{Err_TransformError12, "Internal Transform Error (12)"},
{Err_TransformError13, "Internal Transform Error (13)"},
{Err_TransformError14, "Internal Transform Error (14)"},
{Err_TransformError15, "Internal Transform Error (15)"},
{Err_ScanalyzerError1, "You can't use grayscale or BW images to calibrate color scanners."},
{Err_ScanalyzerError2, "The target image is not big enough to scanalyze.  Re-scan at at higher DPI."},
{Err_ScanalyzerError3, "That image does not appear to be the calibration target, or it is cropped incorrectly."},
{Err_ColorCorrectError1, "That image is not RGB.  You can only color correct RGB images."},

};


void HERE_Error (int code)
{
	if (code != Err_UserAbandon && code != Err_NoError)
		NXRunAlertPanel ("Error", errorTable[code - NX_APPBASE].message, "Ok", NULL, NULL);
}

