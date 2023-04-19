module global
    implicit none
    
    Integer :: i, j, L_x, L_y, U_0_x, U_L_x, U_0_y, U_L_y, nb_points_spatiaux_x, nb_points_spatiaux_y, &
        pas_t_save, compteur_pas_t, step
    Real :: dx, dy, dmin, dt, CFL, Fo, vitesse_convection, coeff_diffusion, tf, t
    Real, dimension(:), allocatable :: maillage_x, maillage_y
    Real, dimension(:,:), allocatable :: tab_n, tab_temp

contains

    ! Importation des données
    subroutine import_input()
        implicit none

        integer :: unit
        character(len=30) :: name
        unit = 26

        open(unit=unit, file="input.dat")

        read(unit,*) name, CFL
        read(unit,*) name, Fo
        read(unit,*) name, vitesse_convection
        read(unit,*) name, coeff_diffusion
        read(unit,*) name, tf
        read(unit,*) name, L_x
        read(unit,*) name, L_y
        read(unit,*) name, U_0_x
        read(unit,*) name, U_L_x
        read(unit,*) name, U_0_y
        read(unit,*) name, U_L_y
        read(unit,*) name, nb_points_spatiaux_x
        read(unit,*) name, nb_points_spatiaux_y
        read(unit,*) name, pas_t_save

        allocate(tab_n(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(tab_temp(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(maillage_x(nb_points_spatiaux_x))
        allocate(maillage_y(nb_points_spatiaux_y))

        close(unit=unit)
    end subroutine import_input

    ! Supprimer et Créer le dossier resultats
    subroutine init_results()
        CALL SYSTEM("rm -r resultats")
        CALL SYSTEM("mkdir resultats")
    end subroutine init_results

    ! Définition du pas spatial en x et y
    subroutine definition_maillage()

        ! maillage x
        do i = 1, nb_points_spatiaux_x
            dx = Real(L_x) / (nb_points_spatiaux_x - 1)
            maillage_x(i) = dx * Real(i-1)
        end do

        ! maillage y
        do i = 1, nb_points_spatiaux_y
            dy = Real(L_y) / (nb_points_spatiaux_y - 1)
            maillage_y(i) = dy * Real(i-1)
        end do

    end subroutine definition_maillage

    ! Initialisation du maillage à t = 0
    subroutine conditions_initiale()

        ! Init tableau
        do j = 2, nb_points_spatiaux_y-1 
            do i = 2, nb_points_spatiaux_x-1
                if ((0.5 < maillage_x(i)) .and. (maillage_x(i) < 1) .and. (0.5 < maillage_y(j)) .and. (maillage_y(j) < 1)) then
                    tab_n(i,j) = 2
                else
                    tab_n(i,j) = 1
                end if
            end do
        end do
        ! Conditions limites
        tab_n(1, :) = U_0_x
        tab_n(nb_points_spatiaux_x, :) = U_L_x
        tab_n(:, 1) = U_0_y
        tab_n(:, nb_points_spatiaux_y) = U_L_y

        ! Sauvegarde dans un fichier .dat au format TECPLOT
        step = 0
        call save_tecplot_format(tab_n)

    end subroutine conditions_initiale

    ! Détermination de la solution finale
    subroutine solution_finale()
        ! Résolution numérique
        t= 0.0
        compteur_pas_t = 1
        do while (t < tf)

            ! détermination du plus petit dx
            dx = L_x
            do i = 1, nb_points_spatiaux_x - 1
                if ((maillage_x(i+1) - maillage_x(i)) < dx) then
                    dx = (maillage_x(i+1) - maillage_x(i))
                end if
            end do
            ! détermination du plus petit dy
            dy = L_y
            do i = 1, nb_points_spatiaux_y - 1
                if ((maillage_y(i+1) - maillage_y(i)) < dy) then
                    dx = (maillage_y(i+1) - maillage_y(i))
                end if
            end do

            ! détermination du plus petit pas spatial
            if (dx < dy) then
                dmin = dx
            else
                dmin = dy
            end if

            dt = CFL * dmin / vitesse_convection
            ! condition de stabilité de Fourrier
            if (dt > Fo * dmin**2 / coeff_diffusion) then
                dt = Fo * dmin**2 / coeff_diffusion
            end if
            t = t + dt

            ! pas y
            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                ! pas x
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    tab_temp(i,j) = tab_n(i,j)*(1-dt*vitesse_convection*(1/dx+1/dy)-2*coeff_diffusion*dt*(1/dx**2 + 1/dy**2)) &
                        + tab_n(i-1,j)*(dt*vitesse_convection/dx + coeff_diffusion*dt/dx**2) &
                        + tab_n(i,j-1)*(dt*vitesse_convection/dy + coeff_diffusion*dt/dy**2) &
                        + tab_n(i+1,j)*coeff_diffusion*dt/dx**2 &
                        + tab_n(i,j+1)*coeff_diffusion*dt/dy**2
                end do
            end do
            
            ! Conditions limites
            tab_temp(1, :) = U_0_x
            tab_temp(nb_points_spatiaux_x, :) = U_L_x
            tab_temp(:, 1) = U_0_y
            tab_temp(:, nb_points_spatiaux_y) = U_L_y

            ! Réaffectation
            tab_n(:,:) = tab_temp(:,:)
            
            if (modulo(compteur_pas_t, pas_t_save) == 0 .or. (t >= tf)) then
                step = step + 1
                ! Sauvegarde dans un fichier .dat au format TECPLOT
                call save_tecplot_format(tab_n)
            end if

            compteur_pas_t = compteur_pas_t + 1
        end do
    end subroutine solution_finale

    subroutine save_tecplot_format(arr)
        implicit none
    
        real, dimension(:,:) :: arr
        INTEGER :: unit
        CHARACTER(LEN=30) :: filename
        unit = 26
        
        write (filename, "(A23, I3.3, A4)") "./resultats/resTECPLOT_", step, ".dat"

        open(unit=unit, file=filename, status='unknown')
            write (unit, *) 'TITLE = "ETAPE3"'
            write (unit, *) 'VARIABLES = "X" , "Y" , "U"'
            write (unit, "(A8, F19.17, A15, I5, A4, I5, A19)") 'ZONE T="', t,'   seconds", I=', &
                nb_points_spatiaux_x, ', J=', nb_points_spatiaux_y, ', DATAPACKING=POINT'
            do j = 1, nb_points_spatiaux_y 
                do i = 1, nb_points_spatiaux_x
                    write (unit, *) maillage_x(i), maillage_y(j), arr(i,j)
                end do
            end do
        close(unit=unit)
        
    end subroutine save_tecplot_format

end module global


program etape1
    use global
    implicit none

    call import_input()
    call delete_results()
    call definition_maillage()
    call conditions_initiale()
    call solution_finale()

end program etape1