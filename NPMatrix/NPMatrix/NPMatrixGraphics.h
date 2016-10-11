//
//  NPMatrixGraphics.h
//  Material Cutter
//
//  Created by Hydra on 15/8/19.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import "NPMatrixType.h"

BOOL NPMatrixGraphicsErosion(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY);

BOOL NPMatrixGraphicsDilation(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY);

BOOL NPMatrixGraphicsOpen(NPMatrixType *G,
                          NPMatrixType *coreEro, unsigned long originEroX, unsigned long originEroY,
                          NPMatrixType *coreDila, unsigned long originDilaX, unsigned long originDilaY);

BOOL NPMatrixGraphicsClose(NPMatrixType *G,
                           NPMatrixType *coreEro, unsigned long originEroX, unsigned long originEroY,
                           NPMatrixType *coreDila, unsigned long originDilaX, unsigned long originDilaY);

BOOL NPMatrixGraphicsOpen1Core(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY);

BOOL NPMatrixGraphicsClose1Core(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY);
