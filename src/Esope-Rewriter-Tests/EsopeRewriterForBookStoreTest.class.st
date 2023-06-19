Class {
	#name : #EsopeRewriterForBookStoreTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'Esope-Rewriter-Tests'
}

{ #category : #tests }
EsopeRewriterForBookStoreTest class >> esopeBigFile [
	^ EsopeGrammarTest esopeBigFile
]

{ #category : #tests }
EsopeRewriterForBookStoreTest class >> esopeBigFileProcessed [
	^ ''
]

{ #category : #tests }
EsopeRewriterForBookStoreTest class >> esopeSmallFile [
	^ EsopeGrammarTest esopeSmallFile
]

{ #category : #tests }
EsopeRewriterForBookStoreTest class >> esopeSmallFileProcessed [
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
cESO  segment string
        character cstg*(lstg)
cESO  endsegment
C
C nlist : capacite de la liste
C ilist : taille   de la liste
C
C PROPRIETE: 0<= ilist <= nlist
C
      integer nlist
cESO  segment,list
        integer ilist
        integer elist(nlist)
cESO  endsegment
C
cESO  pointeur alist.list
cESO  pointeur splist.list
cESO  pointeur rlist.list
      integer  status
C
cESO  pointeur xs.string
cESO  pointeur sp.string
cESO  pointeur ms.string
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
cESO  segini,rlist
      ESOat(rlist,ilist)=0
C
cESO  segact,splist
cESO  segact,alist
C
C     //repeter "decouper chaque chaine"
      do ia=1,ESOat(alist,ilist)
        xs=abs(ESOar(ESOat(alist,elist),ia))
C
cESO    segact,xs
        lxs=ESOsl(ESOat(xs,cstg),1)
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
              if(i.le.(ESOat(splist,ilist)))then
                sp=abs(ESOar(ESOat(splist,elist),i))
cESO            segact,sp
                lsp=ESOsl(ESOat(sp,cstg),1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(ESOar(ESOat(xs,cstg),first:last),
     +                      ESOat(sp,cstg))
                endif
                if(idx.eq.1) then
C                 -- initialiser
                  if(lmin.eq.-1)lmin=lsp
C                 -- favoriser tout separateur-non-vide
                  if(lmin.eq.0)lmin=lsp
C                 -- prendre le plus petit separateur-non-vide
                  if((lsp.lt.lmin).and.(lsp.gt.0))lmin=lsp
                endif
cESO            segdes,sp
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
              if(i.le.(ESOat(splist,ilist)))then
                sp=abs(ESOar(ESOat(splist,elist),i))
cESO            segact,sp
                lsp=ESOsl(ESOat(sp,cstg),1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(ESOar(ESOat(xs,cstg),first:last),
     +                      ESOat(sp,cstg))
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
cESO            segdes,sp
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
cESO          segini,ms
                ESOat(ms,cstg)=ESOar(ESOat(xs,cstg),mfirst:mlast)
cESO          segdes,ms
              ESOat(rlist,ilist)=ESOat(rlist,ilist)+1
              if((ESOat(rlist,ilist)).gt.nlist)then
                nlist=nlist+10
cESO            segadj,rlist
              endif
              ESOar(ESOat(rlist,elist),ESOat(rlist,ilist))=ms          
C
C             //si possible, decouper prochain morceau
              first=mlast+lmin+1
              if(first.le.last)goto 100
            endif
C
C         //fin repeter "decouper morceau"
        endif
C
cESO    segdes,xs
      enddo
C     //fin repeter "decouper chaque chaine"
C
cESO  segdes,alist
cESO  segdes,splist
cESO  segdes,rlist
      return
      end
'
]

{ #category : #accessing }
EsopeRewriterForBookStoreTest >> parserClass [
	^ PPEsopeRewriter 
]

{ #category : #running }
EsopeRewriterForBookStoreTest >> setUp [

	super setUp.
	parser initStream.
	sixSpaces := '      '
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testApplyTransformationTodoAndSlash [
	| actualSource expectedSource |

	actualSource := '         ur.ubb(jr) == ur.ubb(jr + 1) + ur.ubb(/jr)'.
	expectedSource := '         D__(ur,ubb(jr)) == D__(ur,ubb(jr + 1)) + S__(D__(ur,ubb),jr)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testComplexDot [
	| actualSource expectedSource |

	actualSource := '         ur.ubb(jr) == ur.ubb(jr + 1)'.
	expectedSource := '         D__(ur,ubb(jr)) == D__(ur,ubb(jr + 1))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testComplexSlashPointerDotAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = lb.bref(/j/2)'.
	expectedSource := '       brcnt = S__(D__(lb,bref),j/2)'.
	self
		assert:
			(parser applyTransformation: actualSource )
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndArrayAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.a_attr(i)'.
	expectedSource := '       brcnt = D__(ptr,a_attr(i))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndArrayAttributeComplex [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.a_attr(i+j)'.
	expectedSource := '       brcnt = D__(ptr,a_attr(i+j))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndScalarAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.s_attr'.
	expectedSource := '       brcnt = D__(ptr,s_attr)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testFortranLine [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr + a'.
	expectedSource := '       brcnt = ptr + a'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testFortranLineWithDot [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr + a'.
	expectedSource := '       brcnt = ptr + a'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testFortranLineWithOperatorDot [
	| actualSource expectedSource |

	actualSource := '         if ( a.eq.b) then'.
	expectedSource := '         if ( a.eq.b) then'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testSimpleSlashAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.bref(/j)'.
	expectedSource := '       brcnt = S__(D__(ptr,bref),j)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testSimpleSlashAttributeWithoutPrefix [

	| actualSource expectedSource |
	actualSource := '       brcnt = bref(/j)'.
	expectedSource := '       brcnt = S__(bref,j)'.
	self
		assert: (parser applyTransformation: actualSource)
		equals: expectedSource
]
