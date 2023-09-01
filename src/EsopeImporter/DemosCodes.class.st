Class {
	#name : #DemosCodes,
	#superclass : #Object,
	#category : #'EsopeImporter-demos'
}

{ #category : #'filesytem-inmemory' }
DemosCodes class >> borbk [

	^ '      subroutine borbk(lib,name,title)
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy arguments
      pointeur lib.pstr
      character *(*) name
      character *(*) title

c use of external for functions
      external mypnt
      integer mypnt
      external findbk 
      integer findbk
      external findur
      integer findur

c local variables
      pointeur lb.tlib
      pointeur ur.user
      integer ibk,iur
       
      write(*,*) ''borbk: begin''

c activate structure get the first segment and sizes of arrays
      call actstr(lib)
      lb = mypnt(lib,1)
      segact, lb
      brcnt = lb.bref(/1)
      urcnt = lb.uref(/1) 

c see whether the user and the book exist in the structure       
      iur = findur(lib,name)
      if (iur .eq. 0) then 
         write(*,*) '' user'',name,'' does not exist''
         return
      end if 
      ibk = findbk(lib,title)
      if (ibk .eq. 0) then 
         write(*,*) '' book'',title,'' does not exist''
         return
      end if 

c set flag true if the book is borrowed    
      lb.bstatu(brcnt) = .true.

c add the book borrowed to the array  
      ur = mypnt(lib,iur)    
      segact, ur
      ubbcnt = ur.ubb(/1)
      ubbcnt = ubbcnt + 1
      segadj, ur
      ur.ubb(ubbcnt) = ibk       
      segdes, ur*mod

c desactivate head segment  
      segdes,lb*mod

c desactivate structure
      call desstr(lib, ''mod'')
      write(*,*) ''borbk: end''
                    
      end 

'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> findbk [

	^ '      integer function findbk(lib,title)
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy arguments
      pointeur lib.pstr
      character*(*) title

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt

     
c local variables

      pointeur bk.book
      pointeur lb.tlib
      integer ibk
      character*200 fndnam
      logical bkflag

      bkflag = .false.

      call actstr(lib)
      lb = mypnt(lib,1)
      segact, lb       
      urcnt = lb.uref(/1)
      brcnt = lb.bref(/1)
  
      do ibk=1, brcnt
        bk = mypnt(lib,lb.bref(ibk))
        segact, bk
        write(*,*) ''bk'', bk
c       write(*,*) ''book title'', bk.btitle
        fndnam = bk.btitle
        segdes, bk*nomod
        if (trim(fndnam) .eq. trim(title)) then
          bkflag = .true.
          goto 100
        end if
      end do

 100  continue
      segdes, lb*nomod
      call desstr(lib,''nomod'')

      if (bkflag) then
        findbk = ibk
      else
        findbk = 0
      end if
 
      end
'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> findur [

	^ '      integer function findur(lib,name) 
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy arguments
      pointeur lib.pstr
      character*(*) name

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt

c local variables    
      integer iur 
      character*200 fndnam     
      pointeur ur.user
      pointeur lb.tlib
      logical urflag

      urflag = .false.

      call actstr(lib)
      lb = mypnt(lib,1)
      segact, lb       
      urcnt = lb.uref(/1)
      brcnt = lb.bref(/1) 
        
      do iur=1, urcnt
        ur = mypnt(lib,lb.uref(iur))
        segact, ur
        ubbcnt = ur.ubb(/1)
c       write(*,*) "user name", ur.uname
        fndnam = ur.uname
        segdes, ur*nomod
     
     
      if (trim(fndnam) .eq. trim(name)) then
          urflag = .true.
          goto 100
        end if
      end do

 100  continue
      segdes, lb*nomod
      call desstr(lib,''nomod'')

      if (urflag) then
        findur = iur
      else
        findur = 0
      end if
 
      end

'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> libpnt [

	^ '      subroutine libprt(lib)
      implicit none

c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy argument
      pointeur lib.pstr

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt

c local variables     
      pointeur lb.tlib
      pointeur bk.book
      pointeur ur.user

c ibk number of books
c iur number of users
c ibor number of borrowed books
      integer ibk,iur,ibor

      call actstr(lib)
      lb = mypnt(lib,1)
      segact, lb  
  
      brcnt = lb.bref(/1)
      urcnt = lb.uref(/1) 
  
      do ibk=1, brcnt
        bk = mypnt(lib,lb.bref(ibk))
        segact, bk
        write(*,*)''book num'',ibk, bk.btitle, bk.bpages, bk.budc
        segdes, bk*nomod
      end do

c we search in the structure for users and print their names
c pages and udc
      do iur=1, urcnt
        ur = mypnt(lib,lb.uref(iur))
        segact, ur
        write(*,*)''user num'',iur, ur.uname

c we print the books borrowed by the user
        ubbcnt = ur.ubb(/1)
        do ibor=1,ubbcnt
          bk = ur.ubb(ibor)
          segact, bk
          write(*,*) ''>> book'', bk.btitle, bk.bpages, bk.budc

          segdes, bk*nomod
        end do

        segdes, ur*nomod
      end do

c we print the user who borrwed books and the number of books
c borrowed    
      do ibor=1, urcnt
        ur = mypnt(lib,lb.uref(ibor))
        segact, ur
        write(*,*)''user num'',iur, ur.uname , ur.ubb(ibor)
        segdes, ur*nomod
      end do     

c desactivate head segment
      segdes, lb*nomod

c desactivate structure
      call desstr(lib,''nomod'')

      end


'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> main [

	^ '      program main
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c lib structure pstr      
      pointeur lib.pstr
      
     
      write(*,*) ''main: begin''
      
      call ooossg 

      call newlib(lib)  
   
      call newbook(lib,''le petit chaperon rouge'',10,2.12)   

      call newbook(lib,''croc blanc'',100,4.15) 

      call newuser(lib,''emilie'')

      call newuser(lib,''mike'')
     
      call borbk (lib,''mike'', ''croc blanc'')
   
      call relbk(lib, ''mike'', ''croc blanc'')

      call libprt (lib)
          
      call ooostp

      write(*,*) ''main: end''
      end


'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> newbook [

	^ '      subroutine newbook(lib,title,pages,udc)
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy arguments
      pointeur lib.pstr
      character*(*) title
      integer pages
      real udc

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt

c local vriables       
      integer jord    
      pointeur lb.tlib
      pointeur bk.book

            
      write(*,*) ''newbook: begin''

c activate struct
      call actstr(lib) 

c segini book segment           
      segini, bk
      write(*,*) ''newlib: bk''
      bk.btitle = title
      bk.bpages = pages
      bk.budc   = udc
      segdes, bk*mod

c add the segment to the structure  
      call ajpnt(lib,bk,''book '',0,jord)

c get pointeur of segment
      lb = mypnt(lib,1)
      segact, lb
      brcnt = lb.bref(/1)
      urcnt = lb.uref(/1) 
      brcnt = brcnt + 1
      segadj, lb
      lb.bref(brcnt) = jord
      lb.bstatu(brcnt) = .false.
      segdes, lb*mod

c desactivate struct       
      call desstr(lib,''mod'') 

      end 
'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> newlib [

	^ '      subroutine newlib(lib)
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


      pointeur lib.pstr
      pointeur lb.tlib
      integer jord

      brcnt  = 0
      urcnt  = 0
    
      write(*,*) ''newlib: begin''
       
c initialize struct
      call inistr(lib,''test'',3,0)

c activate struct
      call actstr(lib)

      write(*,*) ''newlib: inistr''

c segini head segment
      segini, lb
      segdes, lb*mod
      write(*,*) ''newlib: tlib''

c add the segment to the structure  
      call ajpnt(lib,lb,''tlib'',1,jord)
      write(*,*) ''newlib: jord'', jord

c desactivate struct
      call desstr(lib,''mod'') 
    
      write(*,*) ''newlib: end''

      
      end

'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> newuser [

	^ '      subroutine newuser(lib,name)
      implicit none


c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c pointeur segment
      pointeur lib.pstr
      character *(*) name 

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt

          
c number of segment added
      integer  jord
      pointeur lb.tlib
      pointeur ur.user
     
      write(*,*) ''newuser: begin''

c activate the structure
      call actstr(lib)   

c the user doesnt have a book yet 
      ubbcnt = 0
c segini user segment
      segini, ur
      write(*,*) ''newlib: usr''

c add the name of the user
      ur.uname = name
      segdes, ur*mod

c add the segment to the structure  
      call ajpnt(lib,ur,''user  '',0,jord)

c get pointeur of segment
      lb = mypnt(lib,1)
      segact, lb
      urcnt = lb.uref(/1)
      brcnt = lb.bref(/1)
      urcnt = urcnt + 1
      segadj, lb
      lb.uref(urcnt) = jord
      segdes, lb*mod

c desactivate struct       
      call desstr(lib,''mod'') 

      write(*,*) ''newuser: end''
      end 

'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> plainExample [

	^ 'C234567
      program main
      segment, pers
        character*20 fname,lname
        integer      age
      end segment
      pointeur p1.pers
      segini, p1
      p1.fname = ''John''
      p1.lname = ''Doe''
      p1.age = 42
      p1.names(1) = ''Jane''
      id1 = p1
      call hello(id1)
      segsup, p1
      end
      subroutine hello(idp)
      segment, pers
        character*20 fname,lname
        integer      age
      end segment
      pointeur p1.pers
      p1 = idp
      write(*,*) ''hello: '', p1.fname, '' '',
     + p1.lname, '', '', p1.age
      segsup ,p1
      end
'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> pureF77 [

	^ 'C234567
      subroutine hello(name)
      character*(*) name
      write(*,*) ''hello '', name
      end
      program main
      character*20 fname
      write(*,*)''Enter your name:''
      read(*,*) fname
      call hello(fname)
      end
'
]

{ #category : #'filesytem-inmemory' }
DemosCodes class >> relbk [

	^ '      subroutine relbk(lib,name,title)
      implicit none
c2345678901234567890123456789012345678901234567890123456789012
c bref(brcnt) array of books
c uref(urcnt) array of users
c bstatu(brcnt) logical array of borrowed books
c ubb(ubbcnt) array of books borrowed by the user

c: MAILLON 1
      integer brcnt
      integer urcnt
      integer ubbcnt

c segment de tête
      segment, tlib
        integer bref(brcnt)
        logical bstatu(brcnt)
        integer uref(urcnt)
      end segment

      segment, book
        character*40 btitle
        integer bpages
        real budc
      end segment

      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

c******************************************************************

c2345678901234567890123456789012345678901234567890123456789012
c-pstr
c:pstr   segment dentete des structures : nouvelles definition
*:nomcod nom du code auquel appartient la structure (cronos, apollo, ..)
*:date   date de debut de job
*:heure  heure de debut de job
*:typseg type des segments appartenants a la structure
*:typref type des objects references par la structure
*:ibseg  numero max. du segment ajoute a la structure
*:ibref  numero max. de lobject reference par la structure
*:pntseg pointeurs des segments apartenants a la structure
*:pntref pointeurs des objects references par la structure
      segment, pstr
        character*8 nomcode, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,         pntseg(nbseg), pntref(nbref)
      endsegment
*-------------------------------------------------------------


c dummy arguments
      pointeur lib.pstr
      character *(*) name
      character *(*) title

c use of external for mypnt since it is a function
      external mypnt
      integer mypnt
      external findbk 
      integer findbk
      external findur
      integer findur

c local vriables       
      pointeur lb.tlib
      pointeur ur.user
      pointeur bk.book
      integer ir
      integer ibk

      write(*,*) ''relbk: begin''

c activate struct
      call actstr(lib)
      lb = mypnt(lib,1)
      segact, lb
      brcnt = lb.bref(/1)
      urcnt = lb.uref(/1) 

c call of the function that find the user and check whether
c it belongs to the structure or not and the same thing for the book       
      ur = findur(lib,name)
      if (ur .eq. 0) then 
         write(*,*) '' user'',name,'' does not exist''
         return
      end if 
      ibk = findbk(lib,title)
      if (ibk .eq. 0) then 
         write(*,*) '' book'',title,'' does not exist''
         return
      end if 

c activate the segment user and get the size of the array ubb       
      segact, ur
      ubbcnt = ur.ubb(/1)

c search for the the element that we want to remove from
c the array
      do ir=1, ubbcnt
         if (ur.ubb(ir) .eq. ibk) then 
           exit                      
         end if  
      end do

c adjust the array 
      do jr=ir , ubbcnt-1
c        ur.ubb(jr) == ur.ubb(jr + 1) -> erreur parsing normal
         ur.ubb(jr) = ur.ubb(jr + 1)
      end do

      ubbcnt = ubbcnt - 1   
      segadj, ur
      segdes, ur*mod

c since the book is no more borrowed set flag on false
      lb.bstatu(brcnt) = .false.

c desactivate the head segment  
      segdes,lb*mod

c desactivate structure
      call desstr(lib, ''mod'')

      write(*,*) ''borbk: end''
                    
      end

'
]
