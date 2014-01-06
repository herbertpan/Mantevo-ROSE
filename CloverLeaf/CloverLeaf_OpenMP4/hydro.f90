!Crown Copyright 2012 AWE.
!
! This file is part of CloverLeaf.
!
! CloverLeaf is free software: you can redistribute it and/or modify it under 
! the terms of the GNU General Public License as published by the 
! Free Software Foundation, either version 3 of the License, or (at your option) 
! any later version.
!
! CloverLeaf is distributed in the hope that it will be useful, but 
! WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
! FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
! details.
!
! You should have received a copy of the GNU General Public License along with 
! CloverLeaf. If not, see http://www.gnu.org/licenses/.

!>  @brief Controls the main hydro cycle.
!>  @author Wayne Gaudin
!>  @details Controls the top level cycle, invoking all the drivers and checks
!>  for outputs and completion.

MODULE hydro_cycle_module

CONTAINS

SUBROUTINE hydro_cycle(c,                 &
                       x_min,             &
                       x_max,             &
                       y_min,             &
                       y_max,             &
                       density0,          &
                       density1,          &
                       energy0,           &
                       energy1,           &
                       pressure,          &
                       soundspeed,        &
                       viscosity,         &
                       xvel0,             &
                       yvel0,             &
                       xvel1,             &
                       yvel1,             &
                       vol_flux_x,        &
                       vol_flux_y,        &
                       mass_flux_x,       &
                       mass_flux_y,       &
                       volume,            &
                       work_array1,       &
                       work_array2,       &
                       work_array3,       &
                       work_array4,       &
                       work_array5,       &
                       work_array6,       &
                       work_array7,       &
                       cellx,             &
                       celly,             &
                       celldx,            &
                       celldy,            &
                       vertexx,           &
                       vertexdx,          &
                       vertexy,           &
                       vertexdy,          &
                       xarea,             &
                       yarea,             &
                       left_snd_buffer,   &
                       left_rcv_buffer,   &
                       right_snd_buffer,  &
                       right_rcv_buffer,  &
                       bottom_snd_buffer, &
                       bottom_rcv_buffer, &
                       top_snd_buffer,    &
                       top_rcv_buffer)

  USE clover_module
  USE timestep_module
  USE viscosity_module
  USE PdV_module
  USE accelerate_module
  USE flux_calc_module
  USE advection_module
  USE reset_field_module

  IMPLICIT NONE

  INTEGER               :: c,x_min,x_max,y_min,y_max

  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: density0
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: density1
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: energy0
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: energy1
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: soundspeed
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: pressure
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: viscosity
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: xvel0
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: yvel0
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: xvel1
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: yvel1
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+2) :: vol_flux_x
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+3) :: vol_flux_y
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+2) :: mass_flux_x
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+3) :: mass_flux_y
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+2) :: volume
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array1
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array2
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array3
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array4
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array5
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array6
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+3) :: work_array7
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2) :: cellx
  REAL(KIND=8), DIMENSION(y_min-2:y_max+2) :: celly
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2) :: celldx
  REAL(KIND=8), DIMENSION(y_min-2:y_max+2) :: celldy
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3) :: vertexx
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3) :: vertexdx
  REAL(KIND=8), DIMENSION(y_min-2:y_max+3) :: vertexy
  REAL(KIND=8), DIMENSION(y_min-2:y_max+3) :: vertexdy
  REAL(KIND=8), DIMENSION(x_min-2:x_max+3 ,y_min-2:y_max+2) :: xarea
  REAL(KIND=8), DIMENSION(x_min-2:x_max+2 ,y_min-2:y_max+3) :: yarea
  REAL(KIND=8) :: left_snd_buffer(:),left_rcv_buffer(:),right_snd_buffer(:),right_rcv_buffer(:)
  REAL(KIND=8) :: bottom_snd_buffer(:),bottom_rcv_buffer(:),top_snd_buffer(:),top_rcv_buffer(:)

  INTEGER         :: loc(1)
  REAL(KIND=8)    :: timer,timerstart,wall_clock,step_clock
  
  REAL(KIND=8)    :: grind_time,cells,rstep
  REAL(KIND=8)    :: step_time,step_grind
  REAL(KIND=8)    :: first_step,second_step
  REAL(KIND=8)    :: kernel_total,totals(parallel%max_task)


!$OMP TARGET DATA map(density0,density1,energy0,energy1,pressure,viscosity) &  
!$OMP map(soundspeed,xvel0,xvel1,yvel0,yvel1,vol_flux_x,mass_flux_x,vol_flux_y)& 
!$OMP map(mass_flux_y,work_array1,work_array2,work_array3,work_array4,work_array5)&
!$OMP map(work_array6,work_array7,volume,xarea,yarea,cellx,celly) &
!$OMP map(celldx,celldy,vertexx,vertexdx,vertexy,vertexdy) &   
!$OMP map(left_snd_buffer,left_rcv_buffer,right_snd_buffer,right_rcv_buffer) &
!$OMP map(bottom_snd_buffer,bottom_rcv_buffer,top_snd_buffer,top_rcv_buffer)

  timerstart = timer()
  DO

    step_time = timer()

    step = step + 1

    CALL timestep()

    CALL PdV(.TRUE.)

    CALL accelerate()

    CALL PdV(.FALSE.)

    CALL flux_calc()

    CALL advection()

    CALL reset_field()

    advect_x = .NOT. advect_x
  
    time = time + dt

    IF(summary_frequency.NE.0) THEN
      IF(MOD(step, summary_frequency).EQ.0) CALL field_summary()
    ENDIF
    IF(visit_frequency.NE.0) THEN
      IF(MOD(step, visit_frequency).EQ.0) CALL visit()
    ENDIF

    ! Sometimes there can be a significant start up cost that appears in the first step.
    ! On the short test runs, this can skew the results, so should be taken into account
    !  in recorded run times.
    IF(step.EQ.1) first_step=(timer() - step_time)
    IF(step.EQ.2) second_step=(timer() - step_time)

    IF(time+g_small.GT.end_time.OR.step.GE.end_step) THEN

      complete=.TRUE.
      CALL field_summary()
      IF(visit_frequency.NE.0) CALL visit()

      wall_clock=timer() - timerstart
      IF ( parallel%boss ) THEN
        WRITE(g_out,*)
        WRITE(g_out,*) 'Calculation complete'
        WRITE(g_out,*) 'Clover is finishing'
        WRITE(g_out,*) 'Wall clock ', wall_clock
        WRITE(g_out,*) 'First step overhead', first_step-second_step
        WRITE(    0,*) 'Wall clock ', wall_clock
        WRITE(    0,*) 'First step overhead', first_step-second_step
      ENDIF

      CALL clover_finalize

      EXIT

    END IF

    IF (parallel%boss) THEN
      WRITE(g_out,*)"Wall clock ",timer()-timerstart
      WRITE(0    ,*)"Wall clock ",timer()-timerstart
      cells = grid%x_cells * grid%y_cells
      grind_time   = (timer() - timerstart) / (step * cells)
      step_grind   = (timer() - step_time)/cells
      WRITE(0    ,*)"Average time per cell ",grind_time
      WRITE(g_out,*)"Average time per cell ",grind_time
      WRITE(0    ,*)"Step time per cell    ",step_grind
      WRITE(g_out,*)"Step time per cell    ",step_grind

      IF ( profiler_on ) THEN
        ! First we need to find the maximum kernel time for each task. This
        ! seems to work better than finding the maximum time for each kernel and
        ! adding it up, which always gives over 100%. I think this is because it
        ! does not take into account compute overlaps before syncronisations
        ! caused by halo exhanges.
        kernel_total=profiler%timestep+profiler%ideal_gas+profiler%viscosity+profiler%PdV          &
                    +profiler%revert+profiler%acceleration+profiler%flux+profiler%cell_advection   &
                    +profiler%mom_advection+profiler%reset+profiler%halo_exchange+profiler%summary &
                    +profiler%visit
        CALL clover_allgather(kernel_total,totals)
        ! So then what I do is use the individual kernel times for the
        ! maximum kernel time task for the profile print
        loc=MAXLOC(totals)
        kernel_total=totals(loc(1))
        CALL clover_allgather(profiler%timestep,totals)
        profiler%timestep=totals(loc(1))
        CALL clover_allgather(profiler%ideal_gas,totals)
        profiler%ideal_gas=totals(loc(1))
        CALL clover_allgather(profiler%viscosity,totals)
        profiler%viscosity=totals(loc(1))
        CALL clover_allgather(profiler%PdV,totals)
        profiler%PdV=totals(loc(1))
        CALL clover_allgather(profiler%revert,totals)
        profiler%revert=totals(loc(1))
        CALL clover_allgather(profiler%acceleration,totals)
        profiler%acceleration=totals(loc(1))
        CALL clover_allgather(profiler%flux,totals)
        profiler%flux=totals(loc(1))
        CALL clover_allgather(profiler%cell_advection,totals)
        profiler%cell_advection=totals(loc(1))
        CALL clover_allgather(profiler%mom_advection,totals)
        profiler%mom_advection=totals(loc(1))
        CALL clover_allgather(profiler%reset,totals)
        profiler%reset=totals(loc(1))
        CALL clover_allgather(profiler%halo_exchange,totals)
        profiler%halo_exchange=totals(loc(1))
        CALL clover_allgather(profiler%summary,totals)
        profiler%summary=totals(loc(1))
        CALL clover_allgather(profiler%visit,totals)
        profiler%visit=totals(loc(1))

        IF ( parallel%boss ) THEN
          WRITE(g_out,*)
          WRITE(g_out,'(a58,2f16.4)')"Profiler Output                 Time            Percentage"
          WRITE(g_out,'(a23,2f16.4)')"Timestep              :",profiler%timestep,100.0*(profiler%timestep/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Ideal Gas             :",profiler%ideal_gas,100.0*(profiler%ideal_gas/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Viscosity             :",profiler%viscosity,100.0*(profiler%viscosity/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"PdV                   :",profiler%PdV,100.0*(profiler%PdV/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Revert                :",profiler%revert,100.0*(profiler%revert/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Acceleration          :",profiler%acceleration,100.0*(profiler%acceleration/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Fluxes                :",profiler%flux,100.0*(profiler%flux/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Cell Advection        :",profiler%cell_advection,100.0*(profiler%cell_advection/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Momentum Advection    :",profiler%mom_advection,100.0*(profiler%mom_advection/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Reset                 :",profiler%reset,100.0*(profiler%reset/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Halo Exchange         :",profiler%halo_exchange,100.0*(profiler%halo_exchange/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Summary               :",profiler%summary,100.0*(profiler%summary/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Visit                 :",profiler%visit,100.0*(profiler%visit/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"Total                 :",kernel_total,100.0*(kernel_total/wall_clock)
          WRITE(g_out,'(a23,2f16.4)')"The Rest              :",wall_clock-kernel_total,100.0*(wall_clock-kernel_total)/wall_clock
        ENDIF
      ENDIF
     END IF

  END DO

!$OMP END TARGET DATA

END SUBROUTINE hydro_cycle

END MODULE hydro_cycle_module

SUBROUTINE hydro

  USE clover_module
  USE hydro_cycle_module

  IMPLICIT NONE

  INTEGER         :: cells
  REAL(KIND=8)    :: timer,timerstart

  REAL(KIND=8)    :: grind_time
  REAL(KIND=8)    :: step_time,step_grind

  timerstart = timer()

  CALL hydro_cycle(parallel%task+1,                          &
                   chunks(parallel%task+1)%field%x_min,      &
                   chunks(parallel%task+1)%field%x_max,      &
                   chunks(parallel%task+1)%field%y_min,      &
                   chunks(parallel%task+1)%field%y_max,      &
                   chunks(parallel%task+1)%field%density0,   &
                   chunks(parallel%task+1)%field%density1,   &
                   chunks(parallel%task+1)%field%energy0,    &
                   chunks(parallel%task+1)%field%energy1,    &
                   chunks(parallel%task+1)%field%pressure,   &
                   chunks(parallel%task+1)%field%soundspeed, &
                   chunks(parallel%task+1)%field%viscosity,  &
                   chunks(parallel%task+1)%field%xvel0,      &
                   chunks(parallel%task+1)%field%yvel0,      &
                   chunks(parallel%task+1)%field%xvel1,      &
                   chunks(parallel%task+1)%field%yvel1,      &
                   chunks(parallel%task+1)%field%vol_flux_x, &
                   chunks(parallel%task+1)%field%vol_flux_y, &
                   chunks(parallel%task+1)%field%mass_flux_x,&
                   chunks(parallel%task+1)%field%mass_flux_y,&
                   chunks(parallel%task+1)%field%volume,     &
                   chunks(parallel%task+1)%field%work_array1,&
                   chunks(parallel%task+1)%field%work_array2,&
                   chunks(parallel%task+1)%field%work_array3,&
                   chunks(parallel%task+1)%field%work_array4,&
                   chunks(parallel%task+1)%field%work_array5,&
                   chunks(parallel%task+1)%field%work_array6,&
                   chunks(parallel%task+1)%field%work_array7,&
                   chunks(parallel%task+1)%field%cellx,      &
                   chunks(parallel%task+1)%field%celly,      &
                   chunks(parallel%task+1)%field%celldx,     &
                   chunks(parallel%task+1)%field%celldy,     &
                   chunks(parallel%task+1)%field%vertexx,    &
                   chunks(parallel%task+1)%field%vertexdx,   &
                   chunks(parallel%task+1)%field%vertexy,    &
                   chunks(parallel%task+1)%field%vertexdy,   &
                   chunks(parallel%task+1)%field%xarea,      &
                   chunks(parallel%task+1)%field%yarea,      &
                   chunks(parallel%task+1)%left_snd_buffer,  &
                   chunks(parallel%task+1)%left_rcv_buffer,  &
                   chunks(parallel%task+1)%right_snd_buffer, &
                   chunks(parallel%task+1)%right_rcv_buffer, &
                   chunks(parallel%task+1)%bottom_snd_buffer,&
                   chunks(parallel%task+1)%bottom_rcv_buffer,&
                   chunks(parallel%task+1)%top_snd_buffer,   &
                   chunks(parallel%task+1)%top_rcv_buffer)

END SUBROUTINE hydro

