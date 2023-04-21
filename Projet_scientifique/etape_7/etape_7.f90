module global
    implicit none
    
    Integer, parameter :: DB = SELECTED_REAL_KIND(15,307)
    Integer :: etape_sauvegarde, &
        nb_points_spatiaux_x, nb_points_spatiaux_y, pas_t_save, &
        U_0_x, U_L_x, U_0_y, U_L_y, V_0_x, V_L_x, V_0_y, V_L_y
    Real (kind=DB) :: L_x, L_y, dx, dy, dt, t, CFL, Fo, coeff_diffusion, nu, rho, tf
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
        read(unit,*) name, coeff_diffusion
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
        Integer :: i

        ! maillage x
        do i = 1, nb_points_spatiaux_x
            dx = L_x / (Real(nb_points_spatiaux_x - 1))
            maillage_x(i) = dx * Real(i-1, DB)
        end do

        ! maillage y
        do i = 1, nb_points_spatiaux_y
            dy = L_y / (Real(nb_points_spatiaux_y - 1))
            maillage_y(i) = dy * Real(i-1, DB)
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

        ! Conditions limites u
        u_n(1, :) = U_0_x
        u_n(nb_points_spatiaux_x, :) = U_L_x
        u_n(:, 1) = U_0_y
        u_n(:, nb_points_spatiaux_y) = U_L_y

        ! Conditions limites v
        v_n(1, :) = V_0_x
        v_n(nb_points_spatiaux_x, :) = V_L_x
        v_n(:, 1) = V_0_y
        v_n(:, nb_points_spatiaux_y) = V_L_y

        ! Conditions limites p : A FAIRE
        p_n(1, :) = 0.0_DB
        p_n(nb_points_spatiaux_x, :) = 0.0_DB
        p_n(:, 1) = 0.0_DB
        p_n(:, nb_points_spatiaux_y) = 0.0_DB
        
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

    end subroutine calcul_dt

    ! Détermination du nouveau champs de vitesse u
    subroutine resolution_u()
        implicit none 
        Integer :: i, j

        do j = 2, nb_points_spatiaux_y-1
            dy = maillage_y(j) - maillage_y(j-1)
            ! pas x
            do i = 2, nb_points_spatiaux_x-1
                dx = maillage_x(i) - maillage_x(i-1)
                u_temp(i,j)  = u_n(i,j) + dt*(-u_n(i,j)*(u_n(i,j)-u_n(i-1,j))/dx - v_n(i,j)*(u_n(i,j)-u_n(i,j-1))/dy &
                + nu*((u_n(i+1,j)-2*u_n(i,j)+u_n(i-1,j))/dx**2 + (u_n(i,j+1)-2*u_n(i,j)+u_n(i,j-1))/dy**2) &
                -1/rho * (p_n(i+1,j)-p_n(i-1,j))/(2.0_DB*dx))
                
            end do
        end do
        
    end subroutine resolution_u

    ! Détermination du nouveau champs de vitesse v
    subroutine resolution_v()
        implicit none 
        Integer :: i, j

            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                ! pas x
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)

                    v_temp(i,j)  = v_n(i,j) + dt*(-u_n(i,j)*(v_n(i,j)-v_n(i-1,j))/dx - v_n(i,j)*(v_n(i,j)-v_n(i,j-1))/dy &
                    + nu*((v_n(i+1,j)-2*v_n(i,j)+v_n(i-1,j))/dx**2 + (v_n(i,j+1)-2*v_n(i,j)+v_n(i,j-1))/dy**2) &
                    -1/rho * (p_n(i+1,j)-p_n(i-1,j))/(2.0_DB*dy))

                end do
            end do
        
    end subroutine resolution_v

    ! Détermination du nouveau champs de pression p
    subroutine resolution_p()
        implicit none 
        Integer :: i, j
        Real (kind=DB):: critere_arret, b

        do while (critere_arret >= 10.0_DB**(-6.0_DB))

            do j = 2, nb_points_spatiaux_y-1
                dy = maillage_y(j) - maillage_y(j-1)
                do i = 2, nb_points_spatiaux_x-1
                    dx = maillage_x(i) - maillage_x(i-1)
                    

                    b = rho/dt * ((u_n(i,j)-u_n(i-1,j))/dx + (v_n(i,j)-v_n(i-1,j))/dy) &
                    - rho * (((u_n(i,j)-u_n(i-1,j))/dx)**2 + 2*((v_n(i,j)-v_n(i-1,j))/dx)*((u_n(i,j)-u_n(i,j-1))/dy) &
                    +(v_n(i,j)-v_n(i-1,j))/dy)

                    p_temp(i,j) = dx**2.0_DB*dy**2.0_DB/(2*(dx**2.0_DB+dy**2.0_DB)) *&
                    ((p_n(i+1,j)+p_n(i-1,j))/dx**2.0_DB + (p_n(i,j+1)+p_n(i,j-1))/dy**2.0_DB-b)
                end do
            end do

            do j = 2, nb_points_spatiaux_y-1
                p_temp(1,j) = p_temp(2,j)
                p_temp(nb_points_spatiaux_x,j) = p_temp(nb_points_spatiaux_x - 1,j)
                p_temp(j,1) =  p_temp(j,2)
            end do
            p_temp(1,1) = p_temp(2,2)
            p_temp(1,nb_points_spatiaux_y) = p_temp(2,nb_points_spatiaux_y-1)
            p_temp(nb_points_spatiaux_x,1) = p_temp(nb_points_spatiaux_x-1,2)
            p_temp(nb_points_spatiaux_x,nb_points_spatiaux_y) = p_temp(nb_points_spatiaux_x-1,nb_points_spatiaux_y-1)
            
            critere_arret = 0.0_DB
            do j = 1, nb_points_spatiaux_y
                do i = 1, nb_points_spatiaux_x
                    critere_arret = critere_arret + (p_temp(i,j) - p_n(i,j))**2.0_DB
                end do
            end do

            critere_arret = (critere_arret/(real(nb_points_spatiaux_x, DB)*real(nb_points_spatiaux_y, DB)))**0.5_DB

        end do

        ! Réaffectation p
        p_n(:,:) = p_temp(:,:)
        
    end subroutine resolution_p

    ! Détermination de la solution finale
    subroutine solution_finale()
        implicit none 
        Integer :: compteur_pas_t

        ! Résolution numérique
        t = 0.0_DB
        compteur_pas_t = 1
        dt = 1.0_DB
        do while (t < tf)

            ! Détermination de dt
            call calcul_dt()
            t = t + dt

            ! Résolution de u
            call resolution_u()

            ! Résolution de v
            call resolution_v()

            ! Réafectation des champs de vitesse
            u_n(:,:) = u_temp(:,:)
            v_n(:,:) = v_temp(:,:)

            ! Résolution de p
            call resolution_p()

            if (modulo(compteur_pas_t, pas_t_save) == 0 .or. (t >= tf)) then
                etape_sauvegarde = etape_sauvegarde + 1
                ! Sauvegarde dans un fichier .dat au format TECPLOT
                call save_tecplot_format(u_n, v_n, p_n)
            end if

            compteur_pas_t = compteur_pas_t + 1
            print *, 'ploc'
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


program etape7
    use global
    implicit none

    call import_input()
    call init_results()
    call definition_maillage()
    call conditions_initiale()
    call solution_finale()

end program etape7