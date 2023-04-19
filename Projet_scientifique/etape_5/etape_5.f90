module global
    implicit none
    
    Integer, parameter :: DB = SELECTED_REAL_KIND(10,100)
    Integer :: p_0_x, p_0_y, etape_sauvegarde, &
        nb_points_spatiaux_x, nb_points_spatiaux_y, pas_t_save, nb_iterations
    Real (kind=DB) :: L_x, L_y, dx, dy, dt, t
    Real (kind=DB), dimension(:), allocatable :: maillage_x, maillage_y
    Real (kind=DB), dimension(:,:), allocatable :: p_n, p_temp

contains

    ! Importation des données
    subroutine import_input()
        implicit none

        integer :: unit
        character(len=30) :: name
        unit = 26

        open(unit=unit, file="input.dat")

        read(unit,*) name, nb_iterations
        read(unit,*) name, L_x
        read(unit,*) name, L_y
        read(unit,*) name, p_0_x
        read(unit,*) name, p_0_y
        read(unit,*) name, nb_points_spatiaux_x
        read(unit,*) name, nb_points_spatiaux_y
        read(unit,*) name, pas_t_save

        allocate(p_n(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(p_temp(nb_points_spatiaux_x, nb_points_spatiaux_y))
        allocate(maillage_x(nb_points_spatiaux_x))
        allocate(maillage_y(nb_points_spatiaux_y))

        close(unit=unit)
    end subroutine import_input

    ! Supprimer et Créer le dossier resultats
    subroutine init_results()
        CALL SYSTEM("rm -r resultats")
        CALL SYSTEM("mkdir resultats")
        CALL SYSTEM("rm -r resultatsAnalytique")
        CALL SYSTEM("mkdir resultatsAnalytique")
    end subroutine init_results

    ! Définition du pas spatial en x et y
    subroutine definition_maillage()
        implicit none 
        Integer :: i

        ! maillage x
        do i = 1, nb_points_spatiaux_x
            dx = L_x / (Real(nb_points_spatiaux_x - 1))
            maillage_x(i) = dx * Real(i-1)
        end do

        ! maillage y
        do i = 1, nb_points_spatiaux_y
            dy = L_y / (Real(nb_points_spatiaux_y - 1))
            maillage_y(i) = dy * Real(i-1)
        end do

    end subroutine definition_maillage

    ! Initialisation du maillage à t = 0
    subroutine conditions_initiale()
        implicit none 
        Integer :: i, j

        ! Init tableau p
        do j = 2, nb_points_spatiaux_y-1 
            do i = 2, nb_points_spatiaux_x-1
                p_n(i,j) = 0.0
            end do
        end do
        ! Conditions limites p
        p_n(1, :) = p_0_x
        p_n(:, 1) = p_0_y
        do i = 1, nb_points_spatiaux_x
            p_n(nb_points_spatiaux_x, i) = maillage_x(i)
        end do
        do j = 1, nb_points_spatiaux_y
            p_n(j, nb_points_spatiaux_y) = maillage_y(j)
        end do

        ! Réaffectation p
        p_temp(:,:) = p_n(:,:)

        ! Sauvegarde dans un fichier .dat au format TECPLOT
        etape_sauvegarde = 0
        call save_tecplot_format(p_n)

    end subroutine conditions_initiale

    ! Détermination de la solution finale
    subroutine solution_finale()
        implicit none 
        Integer :: i, j, compteur_pas_t

        ! Résolution numérique
        t = 0.0_DB
        compteur_pas_t = 1
        dt = 1.0_DB
        do while (compteur_pas_t < nb_iterations)

            t = t + dt

            ! Résolution de p
            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    p_temp(i,j) = 1/(2/dx**2 + 2/dy**2)*((p_n(i+1,j) + p_n(i-1,j))/dx**2 + (p_n(i,j+1) + p_n(i,j-1))/dy**2)
                    
                end do
            end do

            ! Réaffectation p
            p_n(:,:) = p_temp(:,:)
            

            if (modulo(compteur_pas_t, pas_t_save) == 0 .or. (compteur_pas_t >= nb_iterations)) then
                etape_sauvegarde = etape_sauvegarde + 1
                ! Sauvegarde dans un fichier .dat au format TECPLOT
                call save_tecplot_format(p_n)
            end if

            compteur_pas_t = compteur_pas_t + 1
        end do
    end subroutine solution_finale

    ! Détermination de la solution analytique
    subroutine solution_analytique()
        implicit none 
        Integer :: i, j
    
        ! Résolution de p
        do j = 1, nb_points_spatiaux_y
            do i = 1, nb_points_spatiaux_x
                p_n(i,j) = maillage_x(i) * maillage_y(j)
            end do
        end do
        t = -1.0_DB ! pour solution analytique
        etape_sauvegarde = 1
        ! Sauvegarde dans un fichier .dat au format TECPLOT
        call save_tecplot_format(p_n)

    end subroutine solution_analytique

    subroutine save_tecplot_format(arr1)
        implicit none
        Integer :: i, j
    
        real (kind=DB), dimension(:,:) :: arr1
        INTEGER :: unit
        CHARACTER(LEN=40) :: filename
        unit = 26
        
        if (t == -1.0_DB) then
            write (filename, "(A33, I3.3, A4)") "./resultatsAnalytique/resTECPLOT_", etape_sauvegarde, ".dat"
        else
            write (filename, "(A23, I3.3, A4)") "./resultats/resTECPLOT_", etape_sauvegarde, ".dat"
        end if

        open(unit=unit, file=filename, status='unknown')
            write (unit, *) 'TITLE = "ETAPE5"'
            write (unit, *) 'VARIABLES = "X" , "Y" , "P"'
            write (unit, "(A8, F19.10, A15, I5, A4, I5, A19)") 'ZONE T="', t,'   seconds", I=', &
                nb_points_spatiaux_x, ', J=', nb_points_spatiaux_y, ', DATAPACKING=POINT'
            do j = 1, nb_points_spatiaux_y 
                do i = 1, nb_points_spatiaux_x
                    write (unit, *) maillage_x(i), maillage_y(j), arr1(i,j)
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
    call solution_analytique()

end program etape4