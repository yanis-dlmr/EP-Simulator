module global
    implicit none
    
    Integer, parameter :: DB = SELECTED_REAL_KIND(15,307)
    Integer :: etape_sauvegarde, nbr_de_coeurs, &
        nb_points_spatiaux_x, nb_points_spatiaux_y, pas_t_save
    Real (kind=DB) :: L_x, L_y, dx, dy, dt, t, CFL, Fo, nu, rho, tf, &
        U_0_x, U_L_x, U_0_y, U_L_y, V_0_x, V_L_x, V_0_y, V_L_y
    Real (kind=DB), dimension(:), allocatable :: maillage_x, maillage_y
    Real (kind=DB), dimension(:,:), allocatable :: u_n, u_temp, v_n, v_temp, p_n, p_temp

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
        read(unit,*) name, nu
        read(unit,*) name, rho
        read(unit,*) name, tf
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
    end subroutine init_results

    ! Définition du pas spatial en x et y
    subroutine definition_maillage()
        implicit none 
        Integer :: i, j

        ! maillage x
        do i = 1, nb_points_spatiaux_x
            dx = L_x / (Real(nb_points_spatiaux_x - 1, DB))
            maillage_x(i) = dx * Real(i-1, DB)
        end do

        ! maillage y
        do j = 1, nb_points_spatiaux_y
            dy = L_y / (Real(nb_points_spatiaux_y - 1, DB))
            maillage_y(j) = dy * Real(j-1, DB)
        end do
    end subroutine definition_maillage

    ! Initialisation du maillage à t = 0
    subroutine conditions_initiale()
        implicit none 
        Integer :: i, j


        ! Init tableau u, v, p
        do j = 1, nb_points_spatiaux_y 
            do i = 1, nb_points_spatiaux_x
                u_n(i,j) = 0.0_DB
                v_n(i,j) = 0.0_DB
                p_n(i,j) = 0.0_DB
            end do
        end do
        
        ! Affectation aux array_temp
        u_temp(:,:) = u_n(:,:)
        v_temp(:,:) = v_n(:,:)
        p_temp(:,:) = p_n(:,:)

        ! Sauvegarde dans un fichier .dat au format TECPLOT
        etape_sauvegarde = 0
        call save_tecplot_format(u_n, v_n, p_n)

    end subroutine conditions_initiale

    ! Détermination du plus petit dt en fonction du CFL et Fourrier
    subroutine calcul_dt()
        implicit none 
        Integer :: i, j
        Real (kind=DB) :: dmin

        ! détermination du plus petit dx
        dx = L_x

        do i = 1, nb_points_spatiaux_x - 1
            if ((maillage_x(i+1) - maillage_x(i)) < dx) then
                dx = (maillage_x(i+1) - maillage_x(i))
            end if
        end do
        ! détermination du plus petit dy
        dy = L_y
        do j = 1, nb_points_spatiaux_y - 1
            if ((maillage_y(j+1) - maillage_y(j)) < dy) then
                dy = (maillage_y(j+1) - maillage_y(j))
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
                if ((CFL * dmin / abs(u_n(i,j)) < dt).AND.(u_n(i,j)/=0)) then
                    dt = CFL * dmin / abs(u_n(i,j))
                end if
                if ((CFL * dmin / abs(u_n(i,j)) < dt).AND.(v_n(i,j)/=0)) then
                    dt = CFL * dmin / abs(v_n(i,j))
                end if
            end do
        end do

        ! condition de stabilité de Fourrier
        if (dt > Fo * dmin**2 / nu) then
            dt = Fo * dmin**2 / nu
        end if

    end subroutine calcul_dt

    ! Détermination du nouveau champs de vitesse u
    subroutine resolution_u()
        implicit none 
        Integer :: i, j
        Real (kind=DB) :: dx_carre, dy_carre


        ! Conditions limites u
        do i = 1, nb_points_spatiaux_x
            u_temp(i, 1) = U_0_y
            u_temp(i, nb_points_spatiaux_y) = U_L_y
        end do

        do j = 1, nb_points_spatiaux_y
                u_temp(1, j) = U_0_x
                u_temp(nb_points_spatiaux_x, j) = U_L_x
        end do

        do j = 2, nb_points_spatiaux_y-1
            dy = maillage_y(j) - maillage_y(j-1)
            dy_carre = dy**2
            ! pas x
            do i = 2, nb_points_spatiaux_x-1
                dx = maillage_x(i) - maillage_x(i-1)
                dx_carre = dx**2
                u_temp(i,j)  = u_n(i,j) + dt*(-u_n(i,j)*(u_n(i,j)-u_n(i-1,j))/dx - v_n(i,j)*(u_n(i,j)-u_n(i,j-1))/dy &
                    + nu*((u_n(i+1,j)-2.0_DB*u_n(i,j)+u_n(i-1,j))/(dx_carre) + (u_n(i,j+1)-2.0_DB*u_n(i,j)+u_n(i,j-1))/(dy_carre)) &
                    -(1.0_DB/rho) * (p_n(i+1,j)-p_n(i-1,j))/(2.0_DB*dx))
            end do
        end do
        
    end subroutine resolution_u

    ! Détermination du nouveau champs de vitesse v
    subroutine resolution_v()
        implicit none 
        Integer :: i, j
        Real (kind=DB) :: dx_carre, dy_carre

        ! Conditions limites v
        do i = 1, nb_points_spatiaux_x
            v_temp(i, 1) = V_0_y
            v_temp(i, nb_points_spatiaux_y) = V_L_y
        end do
        do j = 1, nb_points_spatiaux_y
            v_temp(1, j) = V_0_x
            v_temp(nb_points_spatiaux_x, j) = V_L_x
        end do
        do j = 2, nb_points_spatiaux_y-1
            dy = maillage_y(j) - maillage_y(j-1)
            dy_carre = dy**2

            ! pas x
            do i = 2, nb_points_spatiaux_x-1
                dx = maillage_x(i) - maillage_x(i-1)
                dx_carre = dx**2

                v_temp(i,j)  = v_n(i,j) + dt*(-u_n(i,j)*(v_n(i,j)-v_n(i-1,j))/dx - v_n(i,j)*(v_n(i,j)-v_n(i,j-1))/dy &
                    + nu*((v_n(i+1,j)-2.0_DB*v_n(i,j)+v_n(i-1,j))/(dx_carre) + (v_n(i,j+1)-2.0_DB*v_n(i,j)+v_n(i,j-1)) & 
                    /(dy_carre))-(1.0_DB/rho) * (p_n(i,j+1)-p_n(i,j-1))/(2.0_DB*dy))
            end do

        end do
        
    end subroutine resolution_v

    ! Détermination du nouveau champs de pression p
    subroutine resolution_p()
        implicit none 
        Integer :: i, j
        Real (kind=DB):: critere_arret, b, dx_carre, dy_carre

        !$ write (*, *) "ploc5.1.1"

        critere_arret = 1.0_DB

        do while (critere_arret >= 1e-4_DB)
            ! Conditions limites p
            p_temp(:, nb_points_spatiaux_y) = 0.0_DB
            
            !$OMP PARALLEL PRIVATE (i, j, b) SHARED (p_temp, dx, dy, dx_carre, dy_carre)
            !$OMP DO
            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                dy_carre = dy**2
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    dx_carre = dx**2

                    b = rho/dt * ((u_n(i+1,j)-u_n(i-1,j))/(2.0_DB*dx) + (v_n(i,j+1)-v_n(i,j-1))/(2.0_DB*dy)) &
                        - rho * (((u_n(i+1,j)-u_n(i-1,j))/(2.0_DB*dx))**2 &
                        + 2.0_DB*((v_n(i+1,j)-v_n(i-1,j))/(2.0_DB*dx))*((u_n(i,j+1)-u_n(i,j-1))/(2.0_DB*dy)) &
                        +((v_n(i,j+1)-v_n(i,j-1))/(2.0_DB*dy))**2)

                    p_temp(i,j) = (dx_carre)*(dy_carre)/(2.0_DB*((dx_carre)+(dy_carre))) *&
                        ((p_n(i+1,j)+p_n(i-1,j))/(dx_carre) + (p_n(i,j+1)+p_n(i,j-1))/(dy_carre)-b)
                end do
            end do
            !$OMP END DO
            !$OMP END PARALLEL

            do j = 2, nb_points_spatiaux_y-1
                p_temp(1,j) = p_temp(2,j)
                p_temp(nb_points_spatiaux_x,j) = p_temp(nb_points_spatiaux_x - 1,j)
            end do

            do i = 2, nb_points_spatiaux_x-1
                p_temp(i,1) =  p_temp(i,2)
            end do
            
            do i = 1, nb_points_spatiaux_x
                p_temp(:, 1) = 0.0_DB
            end do

            p_temp(1,1) = p_temp(2,1)
            p_temp(1,nb_points_spatiaux_y) = p_temp(2,nb_points_spatiaux_y)
            p_temp(nb_points_spatiaux_x,1) = p_temp(nb_points_spatiaux_x-1,1)
            p_temp(nb_points_spatiaux_x,nb_points_spatiaux_y) = p_temp(nb_points_spatiaux_x-1,nb_points_spatiaux_y)

            critere_arret = 0.0_DB
            do j = 1, nb_points_spatiaux_y
                do i = 1, nb_points_spatiaux_x
                    critere_arret = critere_arret + (p_temp(i,j) - p_n(i,j))**2.0_DB
                end do
            end do

            critere_arret = (critere_arret/(real(nb_points_spatiaux_x, DB)*real(nb_points_spatiaux_y, DB)))**0.5_DB
            !print *, critere_arret

            ! Réaffectation p
            p_n(:,:) = p_temp(:,:)
        end do

        !$ write (*, *) "ploc5.1.2"
        
    end subroutine resolution_p

    ! Détermination de la solution finale
    subroutine solution_finale()
        implicit none 
        Integer :: compteur_pas_t

        ! Résolution numérique
        t = 0.0_DB
        compteur_pas_t = 1
        dt = 1.0_DB
        do while (t<tf)

            ! Détermination de dt
            call calcul_dt()
            t = t + dt

            ! Résolution de p
            !$ write (*, *) "ploc5.1"
            call resolution_p()
            !$ write (*, *) "ploc5.2"

            ! Résolution de u
            call resolution_u()
            !$ write (*, *) "ploc5.3"
            
            ! Résolution de v
            call resolution_v()
            !$ write (*, *) "ploc5.4"

            ! Réafectation des champs de vitesse
            u_n(:,:) = u_temp(:,:)
            v_n(:,:) = v_temp(:,:)

            if (modulo(compteur_pas_t, pas_t_save) == 0 .or. (t >= tf)) then
                etape_sauvegarde = etape_sauvegarde + 1
                ! Sauvegarde dans un fichier .dat au format TECPLOT
                call save_tecplot_format(u_n, v_n, p_n)
            end if

            compteur_pas_t = compteur_pas_t + 1
        end do

    end subroutine solution_finale

    ! Sauvegarde des différents tableaux au format tecplot
    subroutine save_tecplot_format(arr1, arr2, arr3)
        implicit none
        Integer :: i, j
    
        real (kind=DB), dimension(:,:) :: arr1, arr2, arr3
        INTEGER :: unit
        CHARACTER(LEN=40) :: filename
        unit = 26

        write (filename, "(A23, I3.3, A4)") "./resultats/resTECPLOT_", etape_sauvegarde, ".dat"

        open(unit=unit, file=filename, status='unknown')
            write (unit, *) 'TITLE = "ETAPE7"'
            write (unit, *) 'VARIABLES = "X" , "Y" , "U" , "V" , "P"'
            write (unit, "(A8, F19.10, A15, I5, A4, I5, A19)") 'ZONE T="', t,'   seconds", I=', &
                nb_points_spatiaux_x, ', J=', nb_points_spatiaux_y, ', DATAPACKING=POINT'
            do j = 1, nb_points_spatiaux_y 
                do i = 1, nb_points_spatiaux_x
                    write (unit, *) maillage_x(i), maillage_y(j), arr1(i,j), arr2(i,j), arr3(i,j)
                end do
            end do
        close(unit=unit)
        
    end subroutine save_tecplot_format

end module global


program etape_finale
    use global
    !$ use OMP_LIB
    implicit none

    !$ nbr_de_coeurs = OMP_GET_NUM_PROCS ()
    !$ write (* ,*) " Nombre de coeurs disponibles sur la machine :" ,nbr_de_coeurs

    !$ call OMP_SET_NUM_THREADS (8)
    !$ write (*, *) "ploc1"
    call import_input()
    !$ write (*, *) "ploc2"
    call init_results()
    !$ write (*, *) "ploc3"
    call definition_maillage()
    !$ write (*, *) "ploc4"
    call conditions_initiale()
    !$ write (*, *) "ploc5"
    call solution_finale()
    !$ write (*, *) "ploc6"

end program etape_finale