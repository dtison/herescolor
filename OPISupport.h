#import "AppDefs.h"
#import "/LocalLibrary/HERELibrary/Include/HEREutils.h"
#import "PrinterChipsView.h"
#import "PatternView.h"

@interface OutputProfileInspector (SupportMethods)

- (int) readMeasurementsFromFile: (char *) filename: (ColorV *) colors: (int) count: (BOOL) report;
- (void) pollMessages: (id) panel: (NXRect *) frame;
- (BOOL) abandon;
- (void) initColorWells: (NXColorWell **) colors: (BOOL) enabled;

- previewProcess: (int) process;

- copyFieldsToProfile: (OutputProfile *) profile;
- copyFieldsFromProfile: (OutputProfile *) profile;
- (ColorV *) referenceRcHnColors;		 
- (int) makeTransform: (OutputProfile *) profile;
- (int) cookRenderdict: (OutputProfile *) profile;
- (BOOL) isDocEdited;
- (void) checkCIEModel: (ColorV *) colors;

//-  printVisualRcHnPattern;
//-  printInstrumentRcHnPattern;


char deviceTypeFromMatrix (Matrix *matrix);
void cmslibProgress (Flt done);
BOOL cmslibAbort (void);

@end