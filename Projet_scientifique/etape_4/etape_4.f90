module global
    implicit none
    
    Integer :: i, j, L_x, L_y, U_0_x, U_L_x, U_0_y, U_L_y, V_0_x, V_L_x, V_0_y, V_L_y, &
        nb_points_spatiaux_x, nb_points_spatiaux_y, pas_t_save, compteur_pas_t, step, nb_iterations
    Real :: dx, dy, dmin, dt, CFL, Fo, coeff_diffusion, t
    Real, dimension(:), allocatable :: maillage_x, maillage_y
    Real, dimension(:,:), allocatable :: u_n, u_temp, v_n, v_temp

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
        read(unit,*) name, coeff_diffusion
        read(unit,*) name, nb_iterations
        read(unit,*) name, L_x
        read(unit,*) name, L_y
        read(unit,*) name, U_0_x
        read(unit,*) name, U_L_x
        read(unit,*) name, U_0_y
        read(unit,*) name, U_L_y
        read(unit,*) name, V_0_x
        read(unit,*) name, V_L_x
        read(unit,*) name, V_0_y
        read(unit,*) name, V_L_y
        read(unit,*) name, nb_points_spatiaux_x
        read(unit,*) name, nb_points_spatiaux_y
        read(unit,*) name, pas_t_save

        allocate(u_n(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(u_temp(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(v_n(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(v_temp(nb_points_spatiaux_x, nb_points_spatiaux_y))
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

        ! Init tableau u
        do j = 2, nb_points_spatiaux_y-1 
            do i = 2, nb_points_spatiaux_x-1
                if ((0.5 < maillage_x(i)) .and. (maillage_x(i) < 1) .and. (0.5 < maillage_y(j)) .and. (maillage_y(j) < 1)) then
                    u_n(i,j) = 2
                else
                    u_n(i,j) = 1
                end if
            end do
        end do
        ! Conditions limites u
        u_n(1, :) = U_0_x
        u_n(nb_points_spatiaux_x, :) = U_L_x
        u_n(:, 1) = U_0_y
        u_n(:, nb_points_spatiaux_y) = U_L_y


        ! Init tableau v
        do j = 2, nb_points_spatiaux_y-1 
            do i = 2, nb_points_spatiaux_x-1
                if ((0.5 < maillage_x(i)) .and. (maillage_x(i) < 1) .and. (0.5 < maillage_y(j)) .and. (maillage_y(j) < 1)) then
                    v_n(i,j) = 2
                else
                    v_n(i,j) = 1
                end if
            end do
        end do
        ! Conditions limites v
        v_n(1, :) = V_0_x
        v_n(nb_points_spatiaux_x, :) = V_L_x
        v_n(:, 1) = V_0_y
        v_n(:, nb_points_spatiaux_y) = V_L_y

        ! Sauvegarde dans un fichier .dat au format TECPLOT
        step = 0
        call save_tecplot_format(u_n, v_n)

    end subroutine conditions_initiale

    ! Détermination de la solution finale
    subroutine solution_finale()
        ! Résolution numérique
        t= 0.0
        compteur_pas_t = 1
        dt = 10.0
        do while (compteur_pas_t < nb_iterations)

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
                    dy = (maillage_y(i+1) - maillage_y(i))
                end if
            end do

            ! détermination du plus petit pas spatial
            if (dx < dy) then
                dmin = dx
            else
                dmin = dy
            end if

            do j = 1, nb_points_spatiaux_y
                do i = 1, nb_points_spatiaux_x
                    ! condition de stabilité CFL
                    if (CFL * dmin / u_n(i,j) < dt) then
                        dt = CFL * dmin / u_n(i,j)
                    end if
                    if (CFL * dmin / v_n(i,j) < dt) then
                        dt = CFL * dmin / v_n(i,j)
                    end if
                end do
            end do

            ! condition de stabilité de Fourrier
            if (dt > Fo * dmin**2 / coeff_diffusion) then
                dt = Fo * dmin**2 / coeff_diffusion
            end if

            t = t + dt

            ! Résolution de u
            ! pas y
            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                ! pas x
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    u_temp(i,j) = u_n(i,j) + dt*(u_n(i,j)*(u_n(i-1,j)-u_n(i,j))/dx &
                        + v_n(i,j)*(u_n(i,j-1)-u_n(i,j))/dy + coeff_diffusion &
                        *((u_n(i+1,j) - 2*u_n(i,j) + u_n(i-1,j))/dx**2 &
                        + (u_n(i,j+1) - 2*u_n(i,j) + u_n(i,j-1))/dy**2))
                end do
            end do
            ! Conditions limites u
            u_temp(1, :) = U_0_x
            u_temp(nb_points_spatiaux_x, :) = U_L_x
            u_temp(:, 1) = U_0_y
            u_temp(:, nb_points_spatiaux_y) = U_L_y

            ! Résolution de v
            ! pas y
            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                ! pas x
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    v_temp(i,j) = v_n(i,j) + dt*(u_n(i,j)*(v_n(i-1,j)-v_n(i,j))/dx &
                    + v_n(i,j)*(v_n(i,j-1)-v_n(i,j))/dy + coeff_diffusion &
                    *((v_n(i+1,j) - 2*v_n(i,j) + v_n(i-1,j))/dx**2 &
                    + (v_n(i,j+1) - 2*v_n(i,j) + v_n(i,j-1))/dy**2))
                end do
            end do
            ! Conditions limites v
            v_temp(1, :) = V_0_x
            v_temp(nb_points_spatiaux_x, :) = V_L_x
            v_temp(:, 1) = V_0_y
            v_temp(:, nb_points_spatiaux_y) = V_L_y

            ! Réaffectation u
            u_n(:,:) = u_temp(:,:)
            ! Réaffectation v
            v_n(:,:) = v_temp(:,:)
            

            if (modulo(compteur_pas_t, pas_t_save) == 0 .or. (compteur_pas_t >= nb_iterations)) then
                step = step + 1
                ! Sauvegarde dans un fichier .dat au format TECPLOT
                call save_tecplot_format(u_n, v_n)
            end if

            compteur_pas_t = compteur_pas_t + 1
        end do
    end subroutine solution_finale

    subroutine save_tecplot_format(arr1, arr2)
        implicit none
    
        real, dimension(:,:) :: arr1, arr2
        INTEGER :: unit
        CHARACTER(LEN=30) :: filename
        unit = 26
        
        write (filename, "(A23, I3.3, A4)") "./resultats/resTECPLOT_", step, ".dat"

        open(unit=unit, file=filename, status='unknown')
            write (unit, *) 'TITLE = "ETAPE4"'
            write (unit, *) 'VARIABLES = "X" , "Y" , "U" , "V"'
            write (unit, "(A8, F19.17, A15, I5, A4, I5, A19)") 'ZONE T="', t,'   seconds", I=', &
                nb_points_spatiaux_x, ', J=', nb_points_spatiaux_y, ', DATAPACKING=POINT'
            do j = 1, nb_points_spatiaux_y 
                do i = 1, nb_points_spatiaux_x
                    write (unit, *) maillage_x(i), maillage_y(j), arr1(i,j), arr2(i,j)
                end do
            end do
        close(unit=unit)
        
    end subroutine save_tecplot_format

end module global


program etape4
    use global
    implicit none

    call import_input()
    call init_results()
    call definition_maillage()
    call conditions_initiale()
    call solution_finale()

end program etape4