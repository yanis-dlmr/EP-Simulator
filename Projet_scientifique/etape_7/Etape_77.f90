!projet_scientifique_Etape_7.f95
! Kabir Tasim, Meunier Hugo, EP3
! 24/03/2023
! Equation de Navier-Stokes incompressible

module variables_globales
	implicit none
	integer, parameter :: db = selected_real_kind(15,307)
	integer, parameter :: Nx = 51, Ny = 51 ! Nombre de points du maillage
	integer :: it
	real(kind=db) :: dx, dy, L, t, dt, Fo, CFL, tf, rho, Re
	real(kind=db) , dimension (Nx) :: x, y
	real(kind=db), dimension (Nx,Nx) :: Un, Vn, Ru, Rv, divR
	real(kind=db), dimension (Nx,Ny) :: Pn


contains

subroutine lecture()
	integer :: ios, i
	open (10, file = 'input.dat', status = 'old', iostat = ios)
	if (ios==0) then
		read(10,'(F4.2)') L
		read(10,'(F4.2)') CFL
		read(10,'(F4.2)') Fo
		read(10,'(F4.2)') tf
		read(10,'(F6.1)') rho
		read(10,'(F4.2)') Re
	else
		print *, 'Erreur de lecture de fichier'
	end if
	close(10)

end subroutine lecture


subroutine maillage()
	integer :: i
	
	! calcul du pas d'espace
	dx=L/real(Nx-1)
	dy=L/real(Ny-1)
	!maillage
	do i = 1,Nx
		x(i) = real(i-1)*dx
		y(i) = real(i-1)*dy
	enddo

end subroutine maillage 


subroutine condition_initiale()

	Pn = 0.0_db
	Un = 0.0_db
	Vn = 0.0_db

end subroutine condition_initiale


subroutine resolutionPoisson()
	integer :: i, j
	real(kind=db) :: ek, b
	real(kind=db), dimension (Nx,Ny) :: Pnp1
	
	ek = 0.1_db
	do while (ek > 1e-5_db)
		
		do j = 2,Ny-1
			do i = 2,Nx-1
				b = rho*((Un(i+1,j)-Un(i-1,j))/(2.0_db*dt*dx) &
					+ (Vn(i,j+1)-Vn(i,j-1))/(2.0_db*dt*dy) - divR(i,j))
					
				Pnp1(i,j) = -b*(dx**2*dy**2)/(2.0_db*(dy**2+dx**2)) &
							+(dy**2)/(2.0_db*(dy**2+dx**2)) * (Pn(i+1,j) + Pn(i-1,j)) &
							+(dx**2)/(2.0_db*(dy**2+dx**2)) * (Pn(i,j+1) + Pn(i,j-1))
							
			enddo
		enddo
		
		! Conditions aux limites
		
		Pnp1(1,:)   = Pnp1(2,:) !Conditions limites qui donne les meme images que le prof
		Pnp1(Nx,:)  = Pnp1(Nx,:) !0.0_db
		
		Pnp1(:,1)   = 0.0_db !Pnp1(:,2)
		Pnp1(:,Ny)  = Pnp1(:,Ny-1) 
		
				
		ek = 0.0_db
		do j = 1,Ny
			do i = 1,Nx
				ek = ek + (Pnp1(i,j)-Pn(i,j))**2
			enddo
		enddo
		ek = sqrt(ek/real(Nx*Ny,db))
		Pn = Pnp1
	enddo
	
end subroutine resolutionPoisson

subroutine avancementTemporel()
	integer :: i, j
	real (kind = db) :: Ulim, Vlim, dtx1, dtx2, dty1, dty2, nu
	real(kind=db), dimension (Nx,Ny) :: Unp1, Vnp1

	!Initialisation des variables
	it = 0
	t = 0.0_db
	Ulim = 1.0_db
	Vlim = 0.0_db
	nu = L*Ulim/Re
	
	
	! condition aux limites
	Unp1(:,Ny) = 1.0_db
	
	Unp1(1,:) = 0.0_db
	Unp1(Nx,:) = 0.0_db
	Unp1(:,1) = 0.0_db
	
	Vnp1(1,:) = 0.0_db
	Vnp1(Nx,:) = 0.0_db
	Vnp1(:,1) = 0.0_db
	Vnp1(:,Ny) = 0.0_db
	
	do while (t < tf)
		it = it+1

		t = t+dt
		
		! calcul du pas de temps
		dtx1 = CFL*dx/Ulim
		dty1 = CFL*dy/Vlim
		dtx2 = Fo*(dx**2)/nu
		dty2 = Fo*(dy**2)/nu
		dt = min(dtx1, dty1, dtx2, dty2)
		
		!Calcul du résidu
		do j = 2,Ny-1
			do i = 2,Nx-1
				Ru(i,j) = -(1.0_db/dx)*Un(i,j)*(Un(i,j)-Un(i-1,j)) &
						-(1.0_db/dy)*Vn(i,j)*(Un(i,j)-Un(i,j-1)) &
						+(nu/dx**2)*(Un(i+1,j)-2.0*Un(i,j)+Un(i-1,j)) &
						+(nu/dy**2)*(Un(i,j+1)-2.0*Un(i,j)+Un(i,j-1))
						
						
				Rv(i,j) = -(1.0_db/dx)*Un(i,j)*(Vn(i,j)-Vn(i-1,j))&
						-(1.0_db/dy)*Vn(i,j)*(Vn(i,j)-Vn(i,j-1))&
						+(nu/dx**2)*(Vn(i+1,j)-2.0*Vn(i,j)+Vn(i-1,j)) &
						+(nu/dy**2)*(Vn(i,j+1)-2.0*Vn(i,j)+Vn(i,j-1))
			enddo
		enddo
		
		do j = 2,Ny-1
			do i = 2,Nx-1
				divR(i,j) =(Ru(i+1,j)-Ru(i-1,j))/(2.0_db*dx) + (Rv(i,j+1)-Rv(i,j-1))/(2.0_db*dy)
			enddo
		enddo
		
		!Calcul de Pn
		call resolutionPoisson()
		
		!Calcul de Un+1 et Vn+1
		do j = 2,Ny-1
			do i = 2,Nx-1
				Unp1(i,j) = Un(i,j) &
							-(1.0_db/rho)*(dt/(2.0_db*dx))*(Pn(i+1,j)-Pn(i-1,j)) &
							+dt*Ru(i,j)
				
				Vnp1(i,j) = Vn(i,j)&
							-(1.0_db/rho)*(dt/(2.0_db*dy))*(Pn(i,j+1)-Pn(i,j-1)) &
							+dt*Rv(i,j)
			enddo
		enddo
		Un = Unp1
		Vn = Vnp1
		
		if (0 == mod(it,100)) call ecritureTecplot()
		print *, it
	enddo
end subroutine avancementTemporel



subroutine ecritureTecplot()
	character (len=40) :: filename
	integer :: k,l
	
	write(filename,'("resTECPLOT_",I5.5,".dat")')it
	
	open (10, file=filename)
	write (10,*) 'TITLE = "ETAPE_7"'
	write (10,*) 'VARIABLES = "X", "Y", "U", "V", "P"'
	write (10,'("ZONE T=""",F19.42"   seconds"", I=",I3," J=",I3,", DATAPACKING=POINT")')t,Nx,Ny
	do k = 1,Ny
		do l = 1,Nx
			write(10,*) x(l),y(k),Un(l,k),Vn(l,k),Pn(l,k)
		enddo
	enddo
	close(10)
	
end subroutine ecritureTecplot

end module variables_globales

!program principal
program Etape_7
	use variables_globales
	implicit none

	call lecture()
	call maillage()
	call condition_initiale()
	call ecritureTecplot()
	call avancementTemporel()
	
	
end program Etape_7
