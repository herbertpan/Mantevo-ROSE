c copyright notice
c                      Copyright 2013 Sandia Corporation             
c                                                                    
c     Under the terms of Contract DE-AC04-94AL85000 with Sandia      
c     Corporation, the U.S. Government retains certain rights in this
c     software.                                                      
c                                                                    
c     Redistribution and use in source and binary forms, with or     
c     without modification, are permitted provided that the following
c     conditions are met:                                            
c                                                                    
c      1. Redistributions of source code must retain the above       
c         copyright notice, this list of conditions and the following
c         disclaimer.                                                
c                                                                    
c      2. Redistributions in binary form must reproduce the above    
c         copyright notice, this list of conditions and the following
c         disclaimer in the documentation and/or other materials     
c         provided with the distribution.                            
c                                                                    
c      3. Neither the name of the Corporation nor the names of the   
c         contributors may be used to endorse or promote products    
c         derived from this software without specific prior written  
c         permission.                                                
c                                                                    
c     THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
c     EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,  
c     THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    
c     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA    
c     CORPORATION OR THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT,      
c     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL     
c     DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF         
c     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;   
c     OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  
c     LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      
c     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF  
c     THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
c     SUCH DAMAGE.                                                   
c
c====================================================================
c     
c
c
c  For platforms which do not have libraries of blas level 1 routines,
c  then define the SRCBLAS switch.  This causes the routines in the
c  file blas.f to be compiled.
c

#if defined(CRAY) || defined(sgi)
#define LIBRARYBLAS
#else
#define SRCBLAS
#endif


c
c  Define which version of blas routines to call when linking to
c  an existing library: single or double precision
c

#if defined(D_PRECISION) && defined(LIBRARYBLAS)
#define BLAS_IAMAX IDAMAX
#define BLAS_AXPY DAXPY
#define BLAS_COPY DCOPY
#define BLAS_DOT  DDOT 
#define BLAS_NRM2 DNRM2
#define BLAS_ROT  DROT
#define BLAS_ROTG DROTG
#define BLAS_SCAL DSCAL
#define BLAS_TRSV DTRSV
#define BLAS_GEMV DGEMV
#else
#define BLAS_IAMAX ISAMAX
#define BLAS_AXPY SAXPY
#define BLAS_COPY SCOPY
#define BLAS_DOT  SDOT
#define BLAS_NRM2 SNRM2
#define BLAS_ROT  SROT
#define BLAS_ROTG SROTG
#define BLAS_SCAL SSCAL
#define BLAS_TRSV STRSV
#define BLAS_GEMV SGEMV
#endif
