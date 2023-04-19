module global
    implicit none
    
    Integer :: i, L, U_0, U_L, nb_points_spatiaux, pas_t_save, compteur_pas_t
    Real :: dx, dt, CFL, vitesse_convection, delta, x0, tf, t
    Real, dimension(:), allocatable :: tab_n, tab_temp, maillage_x

contains

    subroutine import_input()
        implicit none

        integer :: unit
        character(len=30) :: name
        unit = 26

        open(unit=unit, file="input.dat")

        read(unit,*) name, CFL
        read(unit,*) name, vitesse_convection
        read(unit,*) name, delta
        read(unit,*) name, x0
        read(unit,*) name, tf
        read(unit,*) name, L
        read(unit,*) name, U_0
        read(unit,*) name, U_L
        read(unit,*) name, nb_points_spatiaux
        read(unit,*) name, pas_t_save

        allocate(tab_n(nb_points_spatiaux))
        allocate(tab_temp(nb_points_spatiaux))
        allocate(maillage_x(nb_points_spatiaux))

        close(unit=unit)
    end subroutine import_input

    ! Supprimer et Créer le dossier resultats
    subroutine init_results()
        CALL SYSTEM("rm -r resultats")
        CALL SYSTEM("mkdir resultats")
    end subroutine init_results

    ! Définition du pas spatial et temporel
    subroutine definition_maillage()
        do i = 0, nb_points_spatiaux - 1
            dx = Real(L) / (nb_points_spatiaux - 1)
            maillage_x(i) = dx * Real(i)
        end do
    end subroutine definition_maillage

    ! Initialisation du maillage à t = 0
    subroutine conditions_initiale()
        ! Init tableau
        do i = 1, nb_points_spatiaux-2                  !tableau allant de 0 à nb_points_spatiaux-1 sans les bornes
            tab_n(i) = exp(-((maillage_x(i) - x0)/delta)**2)
        end do
        tab_n(0) = U_0
        tab_n(nb_points_spatiaux-1) = U_L
        ! Sauvegarde dans un fichier .dat
        call save_array_to_file(tab_n, "./resultats/solution_finale.dat")
        call save_array_to_file(tab_n, "./resultats/solution_analytique.dat")
    end subroutine conditions_initiale

    subroutine solution_finale()
        ! Résolution numérique
        t= 0.0
        compteur_pas_t = 1
        do while (t < tf)
            ! détermination du plus petit dx pour en déduire dt
            dx = L
            do i = 0, nb_points_spatiaux - 2
                if ((maillage_x(i+1) - maillage_x(i)) < dx) then
                    dx = (maillage_x(i+1) - maillage_x(i))
                end if
            end do
            dt = CFL * dx / vitesse_convection
            t = t + dt

            do i = 1, nb_points_spatiaux-2          ! pas spatial
                dx = maillage_x(i) - maillage_x(i-1)
                tab_temp(i) = tab_n(i) + (vitesse_convection*dt/dx) * (tab_n(i-1) - tab_n(i))
            end do
            tab_temp(0) = U_0
            tab_temp(nb_points_spatiaux-1) = U_L
            tab_n(:) = tab_temp(:)
            
            if (modulo(compteur_pas_t, pas_t_save) == 0) then
                ! Sauvegarde dans un fichier .dat
                call add_array_to_file(tab_n, "./resultats/solution_finale.dat")
            end if

            compteur_pas_t = compteur_pas_t + 1
        end do
    end subroutine solution_finale

    subroutine solution_analytique()
        ! Init tableau
        t= 0.0
        compteur_pas_t = 1
        do while (t < tf) ! pas temporel
            ! détermination du plus petit dx pour en déduire dt
            dx = L
            do i = 0, nb_points_spatiaux - 2
                if ((maillage_x(i+1) - maillage_x(i)) < dx) then
                    dx = (maillage_x(i+1) - maillage_x(i))
                end if
            end do
            dt = CFL * dx / vitesse_convection
            t= t+ dt

            do i = 1, nb_points_spatiaux-2 !tableau allant de 0 à nb_points_spatiaux-1 sans les bornes
                tab_n(i) = exp(-((maillage_x(i) - (x0 + vitesse_convection*t))/delta)**2)
            end do
            tab_n(0) = U_0
            tab_n(nb_points_spatiaux-1) = U_L
            if (modulo(compteur_pas_t, pas_t_save) == 0) then
                ! Sauvegarde dans un fichier .dat
                call add_array_to_file(tab_n, "./resultats/solution_analytique.dat")
            end if
            compteur_pas_t = compteur_pas_t + 1
        end do
    end subroutine solution_analytique


    subroutine save_array_to_file(arr, filename)
        implicit none
    
        real, dimension(:) :: arr
        character(len=*), intent(in) :: filename
    
        integer :: i, unit
        unit = 26
    
        open(unit=unit, file=filename)
        do i = 0, size(arr) -1
            write(unit,*) maillage_x(i)
        end do
        write(unit,*) '#'
        do i = 0, size(arr) -1
            write(unit,*) arr(i)
        end do
        write(unit,*) '#'
        close(unit=unit)
    end subroutine save_array_to_file  

    subroutine add_array_to_file(arr, filename)
        implicit none
    
        real, dimension(:) :: arr
        character(len=*), intent(in) :: filename
    
        integer :: i, unit
        unit = 26
    
        open(unit=unit, file=filename, status='old', position='append')
        do i = 0, size(arr) - 1
            write(unit,*) arr(i)
        end do
        write(unit,*) '#'
        close(unit=unit)
    end subroutine add_array_to_file  

end module global



program etape1
    use global
    implicit none

    call import_input()
    call init_results()
    call definition_maillage()
    call conditions_initiale()
    call solution_finale()
    call solution_analytique()

end program etape1
