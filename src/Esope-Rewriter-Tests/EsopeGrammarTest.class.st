Class {
	#name : #EsopeGrammarTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'Esope-Rewriter-Tests'
}

{ #category : #tests }
EsopeGrammarTest class >> esopeBigFile [
	^ '      subroutine vcstp(ov1,pshp1,pbeg1,pend1,ov2,status)
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Cb  Subroutine : vcstp (langage Esope)
Cb  Module     : VECTOR
Cb  Auteur     : L.Brault
Cb  Date       : Octobre-2000
Cb  Service    : EPDN 
Cb  But        : changer une partie des elements avec un vecteur
C
Cm   auteur    : L.Brault
Cm   service   : EPDN
Cm   date      : 31-05-2001
Cm   objet     : corriger l''implementation dans le cas hors colonne
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C
Cae  ov1    : objet VECTOR a changer
Cas  ov1    : objet VECTOR a changer
Cae  pshp1  : shape du VECTOR
Cae  pbeg1  : position de depart
Cae  pend1  : position de fin   
Cas  ov2    : objet VECTOR 
Cas  status : status d''execution (status=0 <=> succes)
C
C
C Fichier a inclure dans tout source PACOME, ESOPE ou FORTRAN.
C
C Utilisation lors de la compilation :
C
C source Fortran :
C  f77 -Dfortran -c -I{repertoires d''inclusion} fichier.F
C
C source Esope :
C  cpp -P -I{repertoires d''inclusion} fichier.E > fichier.e
C
C source Fortran et Esope pour le Cray :
C  cpp -Dcray -I{repertoires d''inclusion} fichier.[F,E] > fichier_source_cray
C
C  Auteur  : L.Caramelle
C  Service : Serlog Systemes.
C  Date    : 28/03/93.
C
C
C  Modif   : G.Martinez
C  Service : EPNC.
C  Date    : 24/08/95.
C  Sujet   : Portage sur CRAY.
C
C  Modif   : M.PONCE
C            (origine L.BRAULT)
C  Service : EPDN
C  Date    : 19/07/2000
C  Sujet   : IMPLICIT_H_INCLUDED
C


      implicit logical (a-z)

C
      integer  mypnt
      external mypnt
C
C
C vectyp         : Type du vecteur soit :
C                  ''FLOTTANT'' , ''ENTIER'' , ''CHAINE'' , ''LOGIQUE'' .
C
C nvcflo         : Nombre de flottant d''un vecteur de type ''FLOTTANT''.
C vecflo(nvcflo) : Vecteur de flottant.
C
C nvcent         : Nombre d''entiers d''un vecteur de type ''ENTIER''.
C vecent(nvcent) : Vecteur d''entiers.
C
C cvccha         : Nombre de caracteres de chaque element d''un vecteur
C                  de type ''CHAINE''.
C nvccha         : Nombre de chaines d''un vecteur de type ''CHAINE''.
C veccha(nvccha) : Vecteur de chaines.
C
C nvclog         : Nombre de logiques d''un vecteur de type ''LOGIQUE''.
C veclog(nvclog) : Vecteur de logiques.
C
C
C N.B : Un objet de type ''VECTOR'' ne peut stocker qu''un seul vecteur de type
C       donne.
C       i.e : Pour un vecteur de type flottant on aura :
C               vectyp = ''FLOTTANT''
C               nvcflo <> 0
C               nvcent  = 0
C               nvclog  = 0
C               nvccha  = 0
C             Etc...
C
C Auteur  : L. Caramelle.
C Service : Serlog Systemes.
C Date    : 12/10/94.
C
C
C Declarations des dimensions des tableaux du segment
C
C
      integer nvcflo
      integer nvcent
      integer cvccha
      integer nvccha
      integer nvclog
C
C Declaration du segment
C
      segment tvecto
        character*8        vectyp
        real               vecflo(nvcflo)
        integer            vecent(nvcent)
        character*(cvccha) veccha(nvccha)
        logical            veclog(nvclog)
      endsegment
      character*16 vvecto
      parameter ( vvecto = ''1.0'' )
C
C values      : valeurs sur un type de base GIBIANE
C valtyp      : type dans {FLOTTANT, ENTIER, LOGIQUE, CHAINE}
C valf(valnf) : valnf FLOTTANT
C vale(valne) : valne ENTIER
C vall(valnl) : valnl LOGIQUE
C valc(valnc) : valnc CHAINE
C vals(valnc) : valnc tailles de CHAINE
C valsmx      : maximum des tailles de CHAINE
C
      integer valnf
C
      integer valne
C
      integer valnl
C
      integer valnc
C
      integer valsmx
C
      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
        logical            vall(valnl)
        character*(valsmx) valc(valnc)
        integer            vals(valnc)
      endsegment
C
      integer  ov2
      integer  ov1
      pointeur pshp1.values
      pointeur pbeg1.values
      pointeur pend1.values
      integer  status
C
      pointeur pv2.tvecto
      pointeur pv1.tvecto
C
      pointeur ppos1.values
      pointeur pbot1.values
      pointeur ptop1.values
      integer  ierr
      integer  v2sz
      integer  v1sz
      integer  shp1sz
      integer  ibeg1
      integer  iend1
      integer  ioff1
      integer  idim1
      integer  iposmx
      integer  ipos
      integer  i
      integer  k
C
      status=0
C
C     -- check version of vector v1
      call vc0ckv(ov1,ierr)
      if (ierr.ne.0) goto 999
C
C     -- check version of vector v2
      call vc0ckv(ov2,ierr)
      if (ierr.ne.0) goto 999
C
C     -- ouvrir le VECTOR v1
      call actstr(ov1)
      pv1=mypnt(ov1,1)
      segact,pv1
      nvcflo=pv1.vecflo(/1)
      nvcent=pv1.vecent(/1)
      nvclog=pv1.veclog(/1)
      nvccha=pv1.veccha(/2)
      cvccha=pv1.veccha(/1)
      v1sz=max(nvcflo,nvcent,nvclog,nvccha)
C
C     -- ouvrir le VECTOR v2
      call actstr(ov2)
      pv2=mypnt(ov2,1)
      segact,pv2
      nvcflo=pv2.vecflo(/1)
      nvcent=pv2.vecent(/1)
      nvclog=pv2.veclog(/1)
      nvccha=pv2.veccha(/2)
      cvccha=pv2.veccha(/1)
      v2sz=max(nvcflo,nvcent,nvclog,nvccha)
C
C     -- verifier le type de v1 et v2
      if(pv1.vectyp .ne. pv2.vectyp)then
        call edmess(''vcstp: arguments de type differents'')
	goto 999
      endif
C
C     -- si shape fournie, verifier compatiblite avec size
      if(pshp1 .ne. 0)then
        segact,pshp1
        iposmx=1
        do i=1,pshp1.vale(/1)
          iposmx=iposmx*pshp1.vale(i)
	enddo
        segdes,pshp1*NOMOD
C
        if(iposmx .ne. v1sz)then
          call edmess(''vcstp: shape et size incompatibles'')
          goto 999
        endif
      endif
C
C     -- retourner begin-1D equivalente a une multi-position
      call vc0pos(pshp1,pbeg1,ibeg1,ierr)
      if(ierr .ne. 0) goto 999
C
C     -- verifier la position de begin
      if(v1sz.ge.1)then
        if(.not.(ibeg1.ge.1 .and. ibeg1.le.v1sz))then
          call edmess(''vcstp: BEGIN hors domaine'')
	  goto 999
	endif
      else
        if(ibeg1.ne.0)then
          call edmess(''vcstp: BEGIN hors domaine'')
	  goto 999
	endif
      endif
C
C     -- retourner end-1D equivalente a une multi-position
      call vc0pos(pshp1,pend1,iend1,ierr)
      if(ierr .ne. 0) goto 999
C
C     -- verifier la position de end
      if(v1sz.ge.1)then
        if(.not.(iend1.ge.1 .and. iend1.le.v1sz))then
          call edmess(''vcstp: END hors domaine'')
	  goto 999
	endif
      else
        if(iend1.ne.0)then
          call edmess(''vcstp: END hors domaine'')
	  goto 999
	endif
      endif
C
C     -- calculer la taille de intervalle [begin, end]
      if(pshp1 .ne. 0)then
        segact,pshp1
        shp1sz=pshp1.vale(/1)
C
        segact,pbeg1
        segact,pend1
        segini,pbot1=pbeg1
        segini,ptop1=pend1
C
        idim1=1
        do i=1,shp1sz
          pbot1.vale(i)=min(pbeg1.vale(i), pend1.vale(i))
          ptop1.vale(i)=max(pbeg1.vale(i), pend1.vale(i))
          idim1=idim1*(ptop1.vale(i) - pbot1.vale(i) + 1)
        enddo
C
      else
        idim1=max(0,iend1-ibeg1+1)
      endif
      if(v1sz .le. 0)then
        idim1=0
      endif
C
C     -- verifier compatibilite [begin, end] et taille de v2
      if(v2sz .ne. idim1)then
        call edmess(
     &  ''vcstp: (BEGIN,END) de v1 et taille de v2 incompatibles'')
	goto 999
      endif
C
C     -- changer les elements
      if(pshp1 .ne. 0)then
C       == multi-indice
C
C       -- positionner au depart tous les indices
        segini,ppos1=pshp1
        do i=1,shp1sz
          ppos1.vale(i)=pbot1.vale(i)
        enddo
C
        do k=1,idim1
C
      	  call vc0pos(pshp1,ppos1,ipos,ierr)
      	  if(ierr .ne. 0) goto 999
	  segact,pshp1
	  segact,ppos1
C
          if(pv1.vectyp .eq. ''FLOTTANT'')then
            pv1.vecflo(ipos)=pv2.vecflo(k)
C
          elseif(pv1.vectyp .eq. ''ENTIER'')then
            pv1.vecent(ipos)=pv2.vecent(k)
C
          elseif(pv1.vectyp .eq. ''LOGIQUE'')then
            pv1.veclog(ipos)=pv2.veclog(k)
C
          elseif(pv1.vectyp .eq. ''CHAINE'')then
            pv1.veccha(ipos)=pv2.veccha(k)
	  endif
C
C         -- incrementer un indice
          do 10, i=1,shp1sz
            if(ppos1.vale(i) .lt. ptop1.vale(i))then
              ppos1.vale(i)=ppos1.vale(i)+1
	      goto 11
            else
              ppos1.vale(i)=pbot1.vale(i)
            endif
 10       continue
 11       continue
C
	enddo
C
        segsup,ppos1
        segsup,pbot1
        segsup,ptop1
C
        segdes,pshp1*NOMOD
        segdes,pbeg1*NOMOD
        segdes,pend1*NOMOD
C
      else
C       == mono-indice
      	ioff1=ibeg1-1
C
      	if(pv1.vectyp .eq. ''FLOTTANT'')then
	  do i=1,v2sz
	    pv1.vecflo(ioff1+i)=pv2.vecflo(i)
	  enddo
C
      	elseif(pv1.vectyp .eq. ''ENTIER'')then
	  do i=1,v2sz
	    pv1.vecent(ioff1+i)=pv2.vecent(i)
	  enddo
C
      	elseif(pv1.vectyp .eq. ''LOGIQUE'')then
	  do i=1,v2sz
	    pv1.veclog(ioff1+i)=pv2.veclog(i)
	  enddo
C
      	elseif(pv1.vectyp .eq. ''CHAINE'')then
	  do i=1,v2sz
	    pv1.veccha(ioff1+i)=pv2.veccha(i)
	  enddo
      	endif
      endif
C
C     -- fermer le VECTOR v2
      segdes,pv2*NOMOD
      call desstr(ov2,''NOMOD'')
C
C     -- fermer le VECTOR v1
      segdes,pv1*MOD
      call desstr(ov1,''MOD'')
C
C     -- terminer avec succes      
      return
C
C     -- terminer en echec
 999  continue      
      call edmess(''vcstp: routine en echec'')
      status=1
      return
      end
'
]

{ #category : #tests }
EsopeGrammarTest class >> esopeFileWithCallStatement [

	^ '      subroutine valrma(
     & pval,
     & status)
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Cb  Subroutine : valrma (langage Esope)
Cb  Module     : VECTOR
Cb  Auteur     : L.Brault
Cb  Date       : Octobre-2000
Cb  Service    : EPDN 
Cb  But        : effacer toutes les valeurs d''un conteneur "values"
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C
Cas  pval   : un conteneur "values"
Cas  status : status d''execution (status=0 <=> succes)
C
C
C Fichier a inclure dans tout source PACOME, ESOPE ou FORTRAN.
C
C Utilisation lors de la compilation :
C
C source Fortran :
C  f77 -Dfortran -c -I{repertoires d''inclusion} fichier.F
C
C source Esope :
C  cpp -P -I{repertoires d''inclusion} fichier.E > fichier.e
C
C source Fortran et Esope pour le Cray :
C  cpp -Dcray -I{repertoires d''inclusion} fichier.[F,E] > fichier_source_cray
C
C  Auteur  : L.Caramelle
C  Service : Serlog Systemes.
C  Date    : 28/03/93.
C
C
C  Modif   : G.Martinez
C  Service : EPNC.
C  Date    : 24/08/95.
C  Sujet   : Portage sur CRAY.
C
C  Modif   : M.PONCE
C            (origine L.BRAULT)
C  Service : EPDN
C  Date    : 19/07/2000
C  Sujet   : IMPLICIT_H_INCLUDED
C


      implicit logical (a-z)

C
C values      : valeurs sur un type de base GIBIANE
C valtyp      : type dans {FLOTTANT, ENTIER, LOGIQUE, CHAINE}
C valf(valnf) : valnf FLOTTANT
C vale(valne) : valne ENTIER
C vall(valnl) : valnl LOGIQUE
C valc(valnc) : valnc CHAINE
C vals(valnc) : valnc tailles de CHAINE
C valsmx      : maximum des tailles de CHAINE
C
      integer valnf
C
      integer valne
C
      integer valnl
C
      integer valnc
C
      integer valsmx
C
      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
        logical            vall(valnl)
        character*(valsmx) valc(valnc)
        integer            vals(valnc)
      endsegment
C
      pointeur      pval.values
      integer       status
C
      status=0
C
C     -- ouvrir le conteneur "values"
      segact,pval
      valnf =pval.valf(/1)
      valne =pval.vale(/1)
      valnl =pval.vall(/1)
      valnc =pval.valc(/2)
      valsmx=pval.valc(/1)
C
C     -- vider le conteneur "values"
      valnf = 0
      valne = 0
      valnl = 0
      valnc = 0
      valsmx= 0
      segadj,pval
C
C     -- fermer le conteneur "values"
      segdes,pval*MOD
C
C     -- terminer avec succes      
      return
C
C     -- terminer en echec
 999  continue      
      call edmess(''valrma: routine en echec'')
      status=1
      return
      end
'
]

{ #category : #tests }
EsopeGrammarTest class >> esopeSmallFile [

	^ '      subroutine stgbrk(
C     == entrees ==
     & alist,splist,
C     == sorties ==
     & rlist,status)
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Cb  Subroutine : stgbrk (langage Esope)
Cb  Module     : STRING
Cb  Auteur     : L.Brault
Cb  Date       : 28-Octobre-1997
Cb  Service    : EPNC 
Cb  But        : briser/decouper des chaines de caracteres
Cb               d''apres une liste de separateurs
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C
Cae  alist  : "la" liste de chaines
Cae  splist : "la" liste de separateurs
C
Cas  rlist  : la liste des morceaux/decoupes de "la" chaine
Cas  status : status d''execution (status=0 <=> succes)
C
C
C Fichier a inclure dans tout source PACOME, ESOPE ou FORTRAN.
C
C Utilisation lors de la compilation :
C
C source Fortran :
C  f77 -Dfortran -c -I{repertoires d''inclusion} fichier.F
C
C source Esope :
C  cpp -P -I{repertoires d''inclusion} fichier.E > fichier.e
C
C source Fortran et Esope pour le Cray :
C  cpp -Dcray -I{repertoires d''inclusion} fichier.[F,E] > fichier_source_cray
C
C  Auteur  : L.Caramelle
C  Service : Serlog Systemes.
C  Date    : 28/03/93.
C
C
C  Modif   : G.Martinez
C  Service : EPNC.
C  Date    : 24/08/95.
C  Sujet   : Portage sur CRAY.
C
C  Modif   : M.PONCE
C            (origine L.BRAULT)
C  Service : EPDN
C  Date    : 19/07/2000
C  Sujet   : IMPLICIT_H_INCLUDED
C


      implicit logical (a-z)

C
C >> verifier que cette implementation est compatible 
C >> avec celle du type CHAINE de GIBIANE/ACROPOL
C 
C lstg : longueur de la chaine de caractere
C cstg : les caracteres de la chaine
C
C PROPRIETE: lstg >= 0
C
      integer lstg
      segment string
        character cstg*(lstg)
      endsegment
C
C nlist : capacite de la liste
C ilist : taille   de la liste
C
C PROPRIETE: 0<= ilist <= nlist
C
      integer nlist
      segment,list
        integer ilist
        integer elist(nlist)
      endsegment
C
      pointeur alist.list
      pointeur splist.list
      pointeur rlist.list
      integer  status
C
      pointeur xs.string
      pointeur sp.string
      pointeur ms.string
      integer  lxs
      integer  lsp
      integer  lmin
      integer  i,ia
      integer  idx,kdx
      integer  first,last
      integer  mfirst,mlast
C
      status=0
      nlist=10
      segini,rlist
      rlist.ilist=0
C
      segact,splist
      segact,alist
C
C     //repeter "decouper chaque chaine"
      do ia=1,alist.ilist
        xs=abs(alist.elist(ia))
C
        segact,xs
        lxs=xs.cstg(/1)
C
        if(lxs.eq.0)then
C         == la chaine a "decouper" est vide
C         >> ne rien renvoyer <<
        else
C         == la chaine a "decouper" n''est pas vide 
          first=1
          last=lxs
C
C         //repeter "decouper morceau"
 100      continue
C
C           //repeter "sauter separateur-tete"
C             -- chercher separateur-entete
C             -- ... donnant le plus petit separateur
 110          i=0
              lmin=-1
 120          i=i+1
              if(i.le.(splist.ilist))then
                sp=abs(splist.elist(i))
                segact,sp
                lsp=sp.cstg(/1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(xs.cstg(first:last),
     +                      sp.cstg)
                endif
                if(idx.eq.1) then
C                 -- initialiser
                  if(lmin.eq.-1)lmin=lsp
C                 -- favoriser tout separateur-non-vide
                  if(lmin.eq.0)lmin=lsp
C                 -- prendre le plus petit separateur-non-vide
                  if((lsp.lt.lmin).and.(lsp.gt.0))lmin=lsp
                endif
                segdes,sp
                goto 120
              endif
C
C             //si trouve, sauter separateur-tete
              if(lmin.ne.-1) then
C               -- sauter separateur-entete
                first=first+lmin
C               //si possible, sauter prochain separateur-tete
                if((first.le.last).and.(lmin.ge.1))goto 110
              endif
C           //fin repeter "sauter separateur-tete"
C
C           //si possible, chercher morceau
            if(first.le.last)then
C             -- chercher separateur-morceau
C             -- ... donnant le plus petit morceau
              i=0
              kdx=0
              lmin=-1
 130          i=i+1
              if(i.le.(splist.ilist))then
                sp=abs(splist.elist(i))
                segact,sp
                lsp=sp.cstg(/1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(xs.cstg(first:last),
     +                      sp.cstg)
                endif
                if(idx.ne.0) then
                  if(kdx.eq.0)then
                    kdx=idx
                    lmin=lsp
                  endif
                  if(idx.lt.kdx)then
                    kdx=idx
                    lmin=lsp
                  endif
                  if((idx.eq.kdx).and.(lsp.lt.lmin))then
                    kdx=idx
                    lmin=lsp
                  endif
                endif
                segdes,sp
                goto 130
              endif
C
C             -- determiner limites morceau
              if(kdx.ne.0) then
                mfirst=first
                if(kdx.eq.1)then
                  mlast=first
                else
                  mlast=first+kdx-2
                endif
              else
                lmin=0
                mfirst=first
                mlast=last
              endif
C
C             -- ranger morceau 
              lstg=mlast-mfirst+1
              segini,ms
                ms.cstg=xs.cstg(mfirst:mlast)
              segdes,ms
              rlist.ilist=rlist.ilist+1
              if((rlist.ilist).gt.nlist)then
                nlist=nlist+10
                segadj,rlist
              endif
              rlist.elist(rlist.ilist)=ms          
C
C             //si possible, decouper prochain morceau
              first=mlast+lmin+1
              if(first.le.last)goto 100
            endif
C
C         //fin repeter "decouper morceau"
        endif
C
        segdes,xs
      enddo
C     //fin repeter "decouper chaque chaine"
C
      segdes,alist
      segdes,splist
      segdes,rlist
      return
      end
'
]

{ #category : #accessing }
EsopeGrammarTest >> parserClass [
	^ PPEsopeGrammar
]

{ #category : #running }
EsopeGrammarTest >> setUp [

	super setUp.
	parser := self parserInstance.
	sixSpaces := '      '.
]

{ #category : #tests }
EsopeGrammarTest >> testBigFile [

	self parse: self class esopeBigFile rule: #file
]

{ #category : #tests }
EsopeGrammarTest >> testEmptyLine [

	self
		parse: '       
'
		rule: #emptyLine
]

{ #category : #tests }
EsopeGrammarTest >> testEndOfLine [

	self parse: String cr rule: #endOfLine.

	self parse: String crlf rule: #endOfLine.

	self parse: String lf rule: #endOfLine
]

{ #category : #tests }
EsopeGrammarTest >> testFortranLine [

	self
		parse: sixSpaces , 'subroutine test(brr)
'
		rule: #fortranLine.

	self parse: String cr rule: #fortranLine
]

{ #category : #tests }
EsopeGrammarTest >> testFortranLineEmpty [

	self
		parse: '
'
		rule: #fortranLine
]

{ #category : #tests }
EsopeGrammarTest >> testInclude [

	self
		parse: '#include <implicit.h>
'
		rule: #include.
	self
		parse: '#include "string.seg"
'
		rule: #include.

	self
		fail: '#include "implicit.h>
'
		rule: #include
]

{ #category : #tests }
EsopeGrammarTest >> testLines [

	| aLine |
	aLine := sixSpaces , 'abc' , String cr.

	self parse: '' rule: #lines.

	self parse: aLine rule: #lines.
	self parse: aLine , aLine , aLine rule: #lines.

	self fail: aLine , (sixSpaces , 'end' , String cr) rule: #lines
]

{ #category : #tests }
EsopeGrammarTest >> testNotEndLine [

	self parse: sixSpaces , 'abc' , String cr rule: #notEndLine.
	self fail: sixSpaces , 'end' , String cr rule: #notEndLine
]

{ #category : #tests }
EsopeGrammarTest >> testOptionalBlanks [

	self parse: '     ' rule: #optionalBlanks.


	self parse: '' rule: #optionalBlanks
]

{ #category : #tests }
EsopeGrammarTest >> testPointer [

	self
		parse: sixSpaces , 'pointeur splist.list
'
		rule: #pointer.
	self fail: 'pointeur splist.list' rule: #pointer
]

{ #category : #tests }
EsopeGrammarTest >> testPointerExtraSpaces [

	self
		parse: '         pointeur splist.list  
'
		rule: #pointer
]

{ #category : #tests }
EsopeGrammarTest >> testSegact [

	self parse: sixSpaces , 'segact,splist' , String cr rule: #segact.
	self parse: sixSpaces , 'segact,pv1' , String cr rule: #segact.
	self parse: sixSpaces , '  segact,xs' , String cr rule: #segact.
	self fail: 'segact,splist' , String cr rule: #segact
]

{ #category : #tests }
EsopeGrammarTest >> testSegadj [

	self
		parse: sixSpaces , 'segadj,alist
'
		rule: #segadj.
	self fail: 'segadj,alist' rule: #segadj
]

{ #category : #tests }
EsopeGrammarTest >> testSegadjVcAcc226 [

	self
		parse: sixSpaces , 'segadj,pval
'
		rule: #segadj.
	self fail: 'segadj,pval' rule: #segadj
]

{ #category : #tests }
EsopeGrammarTest >> testSegdes [

	self
		parse: sixSpaces , 'segdes,alist
'
		rule: #segdes.
	self
		parse: sixSpaces , '  segdes,pshp1*NOMOD
'
		rule: #segdes.
	self fail: 'segdes,alist' rule: #segdes
]

{ #category : #tests }
EsopeGrammarTest >> testSegini [

	self
		parse: sixSpaces , 'segini,rlist
'
		rule: #segini.
	self fail: 'segini,rlist' rule: #segini
]

{ #category : #tests }
EsopeGrammarTest >> testSegment [

	| segment |
	segment := '      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
        logical            vall(valnl)
        character*(valsmx) valc(valnc)
        integer            vals(valnc)
      endsegment
'.
	self parse: segment rule: #segment.
	segment := '      segment string
        character cstg*(lstg)
      endsegment
'.
	self parse: segment rule: #segment.

	self fail: '      segment,values' rule: #segment
]

{ #category : #tests }
EsopeGrammarTest >> testSegmentSimpleWithMoreThanSixSpaces [

	| segment |
	segment := '       segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment
'.
	self parse: segment rule: #segment
]

{ #category : #tests }
EsopeGrammarTest >> testSegsup [

	self
		parse: sixSpaces , 'segsup,rlist
'
		rule: #segsup.
	self fail: 'segsup,rlist' rule: #segsup
]

{ #category : #tests }
EsopeGrammarTest >> testSmallFile [

	"#file is the default rule"

	self parse: self class esopeSmallFile
]

{ #category : #tests }
EsopeGrammarTest >> testStart [

	self parse: self class esopeSmallFile
]
