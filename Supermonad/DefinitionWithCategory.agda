
module Supermonad.DefinitionWithCategory where

-- Stdlib
open import Level
open import Function hiding ( _∘_ ; id )
open import Agda.Primitive
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Data.Nat hiding ( _⊔_ )
open import Data.Vec hiding ( _>>=_ )
open import Data.List hiding ( sequence )
open import Relation.Nullary
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning


open import Utilities
open import Haskell
open import Haskell.Constrained.ConstrainedFunctor
open import Theory.Category
open import Supermonad.Definition

-- -----------------------------------------------------------------------------
-- Definition of a monad extended with a category to repredent an alternative 
-- formalization of supermonads.
-- -----------------------------------------------------------------------------

{-
record Category {ℓ₀ ℓ₁ : Level} (Obj : Set ℓ₀) (Hom : Obj → Obj → Set ℓ₁) : Set (lsuc (ℓ₀ ⊔ ℓ₁)) where
  field
    _∘_ : ∀ {a b c} → Hom b c → Hom a b → Hom a c
    id : ∀ {a} → Hom a a
    
    assoc : {a b c d : Obj} {f : Hom a b} {g : Hom b c} {h : Hom c d} 
          → h ∘ (g ∘ f) ≡ (h ∘ g) ∘ f
    idR : {a b : Obj} {f : Hom a b} → id ∘ f ≡ f
    idL : {a b : Obj} {f : Hom a b} → f ∘ id ≡ f
-}

open Category renaming ( idL to catIdL ; idR to catIdR ; assoc to catAssoc ; _∘_ to comp )

record SupermonadC {ℓ₀ ℓ₁ ℓF : Level} (C : Category {ℓ₀} {ℓ₁}) (M : ∀ {a b} → Hom C a b → TyCon) : Set (lsuc ℓF ⊔ ℓ₀ ⊔ ℓ₁) where
  _∘_ = comp C
  field
    _>>=_ : ∀ {α β : Type} {a b c : Obj C} {i : Hom C a b} {j : Hom C b c} → (M i α → (α → M j β) → M (j ∘ i) β) 
    
    return : ∀ {α : Type} {a : Obj C} → (α → M (id C {a}) α)
    
    functor : {a b : Obj C} (f : Hom C a b) → ConstrainedFunctor {ℓ = ℓF} (M f)
    
    -- The supermonad version of the right identity law.
    idR : {α β : Type} {a b : Obj C} {j : Hom C a b}
        → (a : α) → (k : α → M j β)
        → subst (λ X → M X β) (catIdL C) (return a >>= k) ≡ k a
    
    -- The supermonad version of the left identity law.
    idL : {α : Type} {a b : Obj C} {i : Hom C a b}
        → (m : M i α)
        → subst (λ X → M X α) (catIdR C) (m >>= return) ≡ m
    
    -- The supermonad version of the associativity law.
    assoc : {α β γ : Type} {a b c d : Obj C}
          → {i : Hom C a b} {j : Hom C b c} {k : Hom C c d}
          → (m : M i α) → (f : α → M j β) → (g : β → M k γ)
          → subst (λ X → M X γ) (catAssoc C) ((m >>= f) >>= g) ≡ (m >>= (λ x → f x >>= g))
    
  _>>_ : {α β : Type} {a b c : Obj C}
           → {i : Hom C a b} {j : Hom C b c}
           → M i α → M j β → M (j ∘ i) β
  _>>_ ma mb = ma >>= (λ _ → mb)

  sequence = _>>_
  bind = _>>=_
  
DecidableEquality : ∀ {ℓ} → (A : Set ℓ) → Set ℓ
DecidableEquality A = (a : A) → (b : A) → Dec (a ≡ b)

UniqueHomomorphisms : ∀ {ℓ₀ ℓ₁} → (C : Category {ℓ₀} {ℓ₁}) → Set (ℓ₁ ⊔ ℓ₀)
UniqueHomomorphisms C = ∀ {a b} → (f : Hom C a b) → (g : Hom C a b) → f ≡ g

SupermonadC→Supermonad : {ℓ₀ ℓ₁ : Level} {C : Category {ℓ₀} {ℓ₁}} {F : ∀ {a b} → Hom C a b → Type → Type}
                       → UniqueHomomorphisms C
                       → SupermonadC {ℓ₀} {ℓ₁} {ℓ₀ ⊔ ℓ₁} C F → Supermonad (∃ λ a → ∃ λ b → Hom C a b)
SupermonadC→Supermonad {ℓ₀} {ℓ₁} {C = C} {F = F} uniqueHom smc = record
  { ⟨_⟩ = ⟨_⟩
  ; Binds = Binds
  ; Returns = Returns
  ; functor = functor
  ; tyConArity = 1
  ; tyConArgTys = HomIx ∷ []
  ; tyCon = tyCon
  ; bind = bind
  ; return = return
  ; lawSingleTyCon = lawSingleTyCon
  ; lawUniqueBind = λ {α} {β} → lawUniqueBind {α} {β}
  ; lawUniqueReturn = λ {α} {M} → lawUniqueReturn {α} {M}
  ; lawIdR = lawIdR
  ; lawIdL = lawIdL
  ; lawAssoc = lawAssoc
  ; lawMonadFmap = {!!}
  }
  where
    _∘_ = comp C
    
    HomIx : Set (ℓ₁ ⊔ ℓ₀)
    HomIx = ∃ λ a → ∃ λ b → Hom C a b
    
    ⟨_⟩ : HomIx → TyCon
    ⟨_⟩ (a , b , f) = F f

    tyCon : HomIx → Lift {ℓ = lsuc (ℓ₀ ⊔ ℓ₁)} TyCon
    tyCon (a , b , f) = lift (F f)
    
    Binds : HomIx → HomIx → HomIx → Type → Type → Set (ℓ₁ ⊔ ℓ₀)
    Binds (a , b , f) (b' , c , g) (a' , c' , h) α β = Lift {ℓ = ℓ₁} $ 
      ∃ λ (eqA : a' ≡ a) → 
      ∃ λ (eqB : b ≡ b') → 
      ∃ λ (eqC : c' ≡ c) → 
          (g ∘ subst (Hom C a) eqB f) ≡ (subst₂ (Hom C) eqA eqC h)
    
    Returns : HomIx → Type → Set (ℓ₁ ⊔ ℓ₀)
    Returns (a , a' , f) α = Lift {ℓ = ℓ₁} (a ≡ a')
    
    _>>=_ = SupermonadC.bind smc
    ret = SupermonadC.return smc
    
    bind : {α β : Type} {M N P : HomIx} → Binds M N P α β 
         → ⟨ M ⟩ α → (α → ⟨ N ⟩ β) → ⟨ P ⟩ β
    bind {M = a , b , f} {.b , c , g} {.a , .c , .(g ∘ f)} (lift (refl , refl , refl , refl)) = _>>=_
    
    return : {α : Type} {M : HomIx} → Returns M α 
           → α → ⟨ M ⟩ α
    return {M = a , .a , f} (lift refl) with uniqueHom f (id C {a})
    return {α} {a , .a , .(id C {a})} (lift refl) | refl = ret
    
    functor : (M : HomIx) → ConstrainedFunctor (F (proj₂ (proj₂ M)))
    functor (a , b , f) = record 
      { FunctorCts = ConstrainedFunctor.FunctorCts (SupermonadC.functor smc f)
      ; fmap = ConstrainedFunctor.fmap (SupermonadC.functor smc f)
      ; lawId = ConstrainedFunctor.lawId (SupermonadC.functor smc f)
      ; lawDist = ConstrainedFunctor.lawDist (SupermonadC.functor smc f)
      }
    
    lawSingleTyCon : (M : HomIx) → ∃ (λ i → Lift {ℓ = lsuc (ℓ₀ ⊔ ℓ₁)} (⟨ M ⟩ ≡ lower (tyCon i)))
    lawSingleTyCon (a , b , f) = (a , b , f) , (lift refl)
    
    lawUniqueBind : {α β : Type} {M N P : HomIx} 
                  → (b₁ b₂ : Binds M N P α β) → b₁ ≡ b₂
    lawUniqueBind (lift (refl , refl , refl , refl)) (lift (refl , refl , refl , refl)) = refl
    
    lawUniqueReturn : {α : Type} {M : HomIx}
                    → (r₁ r₂ : Returns M α) → r₁ ≡ r₂
    lawUniqueReturn (lift refl) (lift refl) = refl
    
    bindReplace : {α β : Type} {a b c : Obj C} 
                → {f : Hom C a b} {g : Hom C b c} {h : Hom C a c}
                → (eq : g ∘ f ≡ h)
                → (b : Binds (a , b , f) (b , c , g) (a , c , h) α β)
                → (m : F f α) (k : α → F g β)
                → bind b m k ≡ subst (λ X → F X β) eq (m >>= k) 
    bindReplace refl (lift (refl , refl , refl , refl)) m k = refl
    {-
    returnReplace : {α : Type} {a : Obj C} 
                → {f : Hom C a a}
                → (eq : f ≡ id C {a})
                → (r : Returns (a , a , f) α)
                → (x : α)
                → return r x ≡ ret x
    returnReplace {a = a} {f = .(id C {a})} refl (lift refl) x with uniqueHom (id C {a}) (id C {a})
    returnReplace refl (lift refl) x | refl = refl
    -}
    
    lawIdR : {α β : Type} → (M N : HomIx) → (b : Binds M N N α β) → (r : Returns M α) 
           → (a : α) (k : α → ⟨ N ⟩ β) → bind b (return r a) k ≡ k a
    lawIdR {α} {β} (a , .a , f) (.a , b , g) (lift (refl , refl , refl , f∘g≡g)) (lift refl) x k with uniqueHom f (id C {a})
    lawIdR {α} {β} (a , .a , .(id C {a})) (.a , b , g) (lift (refl , refl , refl , f∘g≡g)) (lift refl) x k | refl = begin
      bind (lift (refl , refl , refl , f∘g≡g)) (ret x) k
        ≡⟨ bindReplace f∘g≡g (lift (refl , refl , refl , f∘g≡g)) (ret x) k ⟩
      subst (λ X → F X β) f∘g≡g (ret x >>= k)
        ≡⟨ cong (λ Y → subst (λ X → F X β) Y (ret x >>= k)) (proof-irrelevance f∘g≡g (catIdL C {f = g})) ⟩
      subst (λ X → F X β) (catIdL C {f = g}) (ret x >>= k)
        ≡⟨ SupermonadC.idR smc x k ⟩
      k x ∎
    
    lawIdL : {α : Type} 
           → (M N : HomIx)
           → (b : Binds M N M α α) → (r : Returns N α)
           → (m : ⟨ M ⟩ α) 
           → bind b m (return r) ≡ m
    lawIdL {α} (a , b , f) (.b , .b , g) (lift (refl , refl , refl , g∘f≡f)) (lift refl) m with uniqueHom g (id C {b})
    lawIdL {α} (a , b , f) (.b , .b , .(id C {b})) (lift (refl , refl , refl , g∘f≡f)) (lift refl) m | refl = begin
      bind (lift (refl , refl , refl , g∘f≡f)) m ret 
        ≡⟨ bindReplace g∘f≡f (lift (refl , refl , refl , g∘f≡f)) m ret ⟩
      subst (λ X → F X α) g∘f≡f (m >>= ret) 
        ≡⟨ cong (λ Y → subst (λ X → F X α) Y (m >>= ret)) (proof-irrelevance g∘f≡f (catIdR C {f = f})) ⟩
      subst (λ X → F X α) (catIdR C {f = f}) (m >>= ret) 
        ≡⟨ SupermonadC.idL smc m ⟩
      m ∎
    
    lawAssoc : {α β γ : Type} 
             → (M N P S T : HomIx)
             → (b₁ : Binds M N P α γ) → (b₂ : Binds S T N β γ)
             → (b₃ : Binds N T P β γ) → (b₄ : Binds M S N α β) 
             → (m : ⟨ M ⟩ α) → (f : α → ⟨ S ⟩ β) → (g : β → ⟨ T ⟩ γ)
             → bind b₁ m (λ x → bind b₂ (f x) g) ≡ bind b₃ (bind b₄ m f) g
    lawAssoc {α} {β} {γ} (a1 , .a1 , f1) (.a1 , b2 , .(f5 ∘ f4)) (.a1 , .b2 , .((f5 ∘ f4) ∘ f1)) (.a1 , .b2 , f4) (.b2 , .b2 , f5) 
             (lift (refl , refl , refl , refl)) (lift (refl , refl , refl , refl)) (lift (refl , refl , refl , f4∘f1≡f5∘f4)) (lift (refl , refl , refl , f5∘f5∘f4≡f5∘f4∘f1))
             m k l with uniqueHom f1 (id C {a = a1}) | uniqueHom f5 (id C {a = b2})
    lawAssoc {α} {β} {γ} (a1 , .a1 , .(id C {a = a1})) (.a1 , b2 , .(id C {a = b2} ∘ f4)) (.a1 , .b2 , .((id C {a = b2} ∘ f4) ∘ id C {a = a1})) (.a1 , .b2 , f4) (.b2 , .b2 , .(id C {a = b2})) 
             (lift (refl , refl , refl , refl)) (lift (refl , refl , refl , refl)) (lift (refl , refl , refl , f5∘f5∘f4≡f5∘f4∘f1)) (lift (refl , refl , refl , f4∘f1≡f5∘f4))
             m k l | refl | refl = begin
      m >>= (λ x → k x >>= l)
        ≡⟨ sym (SupermonadC.assoc smc m k l) ⟩
      subst (λ X → F X γ) (catAssoc C) ((m >>= k) >>= l)
        ≡⟨ cong (λ Y → subst (λ X → F X γ) Y ((m >>= k) >>= l)) (proof-irrelevance (catAssoc C) (trans (cong (_∘_ (id C {b2})) f4∘f1≡f5∘f4) f5∘f5∘f4≡f5∘f4∘f1)) ⟩
      subst (λ X → F X γ) (trans (cong (_∘_ (id C {b2})) f4∘f1≡f5∘f4) f5∘f5∘f4≡f5∘f4∘f1) ((m >>= k) >>= l)
        ≡⟨ sym (substTrans (cong (_∘_ (id C {b2})) f4∘f1≡f5∘f4) f5∘f5∘f4≡f5∘f4∘f1 (λ Z → F Z γ) ((m >>= k) >>= l)) ⟩
      subst (λ X → F X γ) f5∘f5∘f4≡f5∘f4∘f1 (subst (λ X → F X γ) (cong (_∘_ (id C {b2})) f4∘f1≡f5∘f4) ((m >>= k) >>= l))
        ≡⟨ cong (λ Y → subst (λ X → F X γ) f5∘f5∘f4≡f5∘f4∘f1 Y) (sym (help (m >>= k) l f4∘f1≡f5∘f4)) ⟩
      subst (λ X → F X γ) f5∘f5∘f4≡f5∘f4∘f1 ((subst (λ X → F X β) f4∘f1≡f5∘f4 (m >>= k)) >>= l)
        ≡⟨ cong (λ Y → subst (λ X → F X γ) f5∘f5∘f4≡f5∘f4∘f1 (Y >>= l)) (sym (bindReplace f4∘f1≡f5∘f4 (lift (refl , refl , refl , f4∘f1≡f5∘f4)) m k)) ⟩
      subst (λ X → F X γ) f5∘f5∘f4≡f5∘f4∘f1 ((bind (lift (refl , refl , refl , f4∘f1≡f5∘f4)) m k) >>= l)
        ≡⟨ sym (bindReplace f5∘f5∘f4≡f5∘f4∘f1 (lift (refl , refl , refl , f5∘f5∘f4≡f5∘f4∘f1)) (bind (lift (refl , refl , refl , f4∘f1≡f5∘f4)) m k) l) ⟩
      bind (lift (refl , refl , refl , f5∘f5∘f4≡f5∘f4∘f1)) (bind (lift (refl , refl , refl , f4∘f1≡f5∘f4)) m k) l ∎
      where
        help : {α β : Type} {a b c : Obj C} {f g : Hom C a b} {h : Hom C b c}
             → (m : F f α) → (k : α → F h β)
             → (eq : f ≡ g)
             → ((subst (λ X → F X α) eq m) >>= k) ≡ subst (λ X → F X β) (cong (_∘_ h) eq) (m >>= k)
        help m k refl = refl
