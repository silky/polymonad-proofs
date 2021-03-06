 
module Polymonad.Union.Principal.Utilities where

open import Data.Product
open import Data.Sum
open import Data.Empty
open import Relation.Binary.PropositionalEquality

open import Utilities
open import Identity
open import Polymonad.Definition
open import Polymonad.Unionable
open import Polymonad.Union
open import Polymonad.Principal

private i₂i₂ : ∀ {IdTC TC₁ TC₂ : Set} → TC₂ → IdTC ⊎ (TC₁ ⊎ TC₂)
i₂i₂ N = inj₂ (inj₂ N)

private i₂i₁ : ∀ {IdTC TC₁ TC₂ : Set} → TC₁ → IdTC ⊎ (TC₁ ⊎ TC₂)
i₂i₁ N = inj₂ (inj₁ N)

mTyCon₁ : ∀ {TyCons₁ TyCons₂ : Set} → IdTyCons ⊎ TyCons₁ → IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)
mTyCon₁ (inj₁ IdTyCon) = inj₁ IdTyCon
mTyCon₁ (inj₂ M) = inj₂ (inj₁ M)

mTyCon₂ : ∀ {TyCons₁ TyCons₂ : Set} → IdTyCons ⊎ TyCons₂ → IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)
mTyCon₂ (inj₁ IdTyCon) = inj₁ IdTyCon
mTyCon₂ (inj₂ M) = inj₂ (inj₂ M)

pairIn1→⊥ : ∀ {TyCons₁ TyCons₂ : Set}
          → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
          → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
            → (M , M') ∈ F 
            → ∃ λ(M₁ : IdTyCons ⊎ TyCons₁) → ∃ λ(M₁' : IdTyCons ⊎ TyCons₁) 
            → (M ≡ mTyCon₁ M₁) × (M' ≡ mTyCon₁ M₁') )
          → (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))
          → (N , N') ∈ F
          → (∃ λ(M : TyCons₂) → N ≡ i₂i₂ M ⊎ N' ≡ i₂i₂ M)
          → ⊥
pairIn1→⊥ F pairIn1 N N' NN'∈F (M , N≡M) with pairIn1 N N' NN'∈F
pairIn1→⊥ F pairIn1 .(inj₂ (inj₂ M)) N' NN'∈F (M , inj₁ refl) | inj₁ IdentTC , P' , () , eq2
pairIn1→⊥ F pairIn1 .(inj₂ (inj₂ M)) N' NN'∈F (M , inj₁ refl) | inj₂ P , P' , () , eq2
pairIn1→⊥ F pairIn1 N .(inj₂ (inj₂ M)) NN'∈F (M , inj₂ refl) | P , inj₁ IdentTC , eq1 , ()
pairIn1→⊥ F pairIn1 N .(inj₂ (inj₂ M)) NN'∈F (M , inj₂ refl) | P , inj₂ P' , eq1 , ()

pairIn2→⊥ : ∀ {TyCons₁ TyCons₂ : Set}
          → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
          → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
            → (M , M') ∈ F 
            → ∃ λ(M₂ : IdTyCons ⊎ TyCons₂) → ∃ λ(M₂' : IdTyCons ⊎ TyCons₂) 
            → (M ≡ mTyCon₂ M₂) × (M' ≡ mTyCon₂ M₂') )
          → (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))
          → (N , N') ∈ F
          → (∃ λ(M : TyCons₁) → N ≡ i₂i₁ M ⊎ N' ≡ i₂i₁ M)
          → ⊥
pairIn2→⊥ F pairIn2 N N' NN'∈F (M , N≡M) with pairIn2 N N' NN'∈F
pairIn2→⊥ F pairIn2 .(inj₂ (inj₁ M)) N' NN'∈F (M , inj₁ refl) | inj₁ IdentTC , P' , () , eq
pairIn2→⊥ F pairIn2 .(inj₂ (inj₁ M)) N' NN'∈F (M , inj₁ refl) | inj₂ P , P' , () , eq
pairIn2→⊥ F pairIn2 N .(inj₂ (inj₁ M)) NN'∈F (M , inj₂ refl) | P , inj₁ P' , eq , ()
pairIn2→⊥ F pairIn2 N .(inj₂ (inj₁ M)) NN'∈F (M , inj₂ refl) | P , inj₂ P' , eq , ()

F→F₁ : ∀ {TyCons₁ TyCons₂ : Set} 
     → SubsetOf ((IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))) 
     → SubsetOf ((IdTyCons ⊎ TyCons₁) × (IdTyCons ⊎ TyCons₁))
F→F₁ F (inj₁ IdentTC , inj₁ IdentTC) = F (idTC , idTC)
F→F₁ F (inj₁ IdentTC , inj₂ N') = F (idTC , i₂i₁ N')
F→F₁ F (inj₂ N , inj₁ IdentTC) = F (i₂i₁ N , idTC)
F→F₁ F (inj₂ N , inj₂ N') = F (i₂i₁ N , i₂i₁ N')

F→F₂ : ∀ {TyCons₁ TyCons₂ : Set} 
     → SubsetOf ((IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))) 
     → SubsetOf ((IdTyCons ⊎ TyCons₂) × (IdTyCons ⊎ TyCons₂))
F→F₂ F (inj₁ IdentTC , inj₁ IdentTC) = F (idTC , idTC)
F→F₂ F (inj₁ IdentTC , inj₂ N') = F (idTC , i₂i₂ N')
F→F₂ F (inj₂ N , inj₁ IdentTC) = F (i₂i₂ N , idTC)
F→F₂ F (inj₂ N , inj₂ N') = F (i₂i₂ N , i₂i₂ N')

NN∈F→NN∈F₁ : ∀ {TyCons₁ TyCons₂ : Set}
           → ( F : SubsetOf ((IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))) )
           → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₁ : IdTyCons ⊎ TyCons₁) → ∃ λ(M₁' : IdTyCons ⊎ TyCons₁) 
               → (M ≡ mTyCon₁ M₁) × (M' ≡ mTyCon₁ M₁') ) 
           → (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) → (N , N') ∈ F 
           → ∃ λ(P : IdTyCons ⊎ TyCons₁) → ∃ λ(P' : IdTyCons ⊎ TyCons₁) → (P , P') ∈ (F→F₁ F)
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F = inj₁ IdentTC , inj₁ IdentTC , NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₂ (inj₁ N')) NN'∈F = inj₁ IdentTC , inj₂ N' , NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F with pairIn1 idTC (i₂i₂ N') NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F | inj₁ IdentTC , inj₁ IdentTC , refl , ()
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F | inj₁ IdentTC , inj₂ P' , refl , ()
NN∈F→NN∈F₁ F pairIn1 (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F | inj₂ P , P' , () , eq
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₁ IdentTC) NN'∈F = inj₂ N , inj₁ IdentTC , NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₂ (inj₁ N')) NN'∈F = inj₂ N , inj₂ N' , NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F with pairIn1 (i₂i₁ N) (i₂i₂ N') NN'∈F 
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F | inj₁ IdentTC , P' , () , eq
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F | inj₂ .N , inj₁ IdentTC , refl , ()
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F | inj₂ .N , inj₂ P' , refl , ()
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₂ N)) N' NN'∈F with pairIn1 (i₂i₂ N) N' NN'∈F
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₂ N)) .(mTyCon₁ P') NN'∈F | inj₁ IdentTC , P' , () , refl
NN∈F→NN∈F₁ F pairIn1 (inj₂ (inj₂ N)) .(mTyCon₁ P') NN'∈F | inj₂ P , P' , () , refl

NN∈F→NN∈F₂ : ∀ {TyCons₁ TyCons₂ : Set}
           → ( F : SubsetOf ((IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))) )
           → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₂ : IdTyCons ⊎ TyCons₂) → ∃ λ(M₂' : IdTyCons ⊎ TyCons₂) 
               → (M ≡ mTyCon₂ M₂) × (M' ≡ mTyCon₂ M₂') ) 
           → (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) → (N , N') ∈ F 
           → ∃ λ(P : IdTyCons ⊎ TyCons₂) → ∃ λ(P' : IdTyCons ⊎ TyCons₂) → (P , P') ∈ (F→F₂ F)
NN∈F→NN∈F₂ F pairIn2 (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F = idTC , idTC , NN'∈F
NN∈F→NN∈F₂ F pairIn2 (inj₁ IdentTC) (inj₂ (inj₁ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 idTC (i₂i₁ N') NN'∈F (N' , inj₂ refl))
NN∈F→NN∈F₂ F pairIn2 (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F = idTC , inj₂ N' , NN'∈F
NN∈F→NN∈F₂ F pairIn2 (inj₂ (inj₁ N)) N' NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₁ N) N' NN'∈F (N , inj₁ refl))
NN∈F→NN∈F₂ F pairIn2 (inj₂ (inj₂ N)) (inj₁ IdentTC) NN'∈F = inj₂ N , idTC , NN'∈F
NN∈F→NN∈F₂ F pairIn2 (inj₂ (inj₂ N)) (inj₂ (inj₁ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₂ N) (i₂i₁ N') NN'∈F (N' , inj₂ refl))
NN∈F→NN∈F₂ F pairIn2 (inj₂ (inj₂ N)) (inj₂ (inj₂ N')) NN'∈F = inj₂ N , inj₂ N' , NN'∈F

NN∈F₁→NN∈F : ∀ {TyCons₁ TyCons₂ : Set}
           → ( F : SubsetOf ((IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂))) )
           → (N N' : IdTyCons ⊎ TyCons₁) → (N , N') ∈ F→F₁ F 
           → (mTyCon₁ N , mTyCon₁ N') ∈ F
NN∈F₁→NN∈F F (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F₁ = NN'∈F₁
NN∈F₁→NN∈F F (inj₁ IdentTC) (inj₂ N') NN'∈F₁ = NN'∈F₁
NN∈F₁→NN∈F F (inj₂ N) (inj₁ IdentTC) NN'∈F₁ = NN'∈F₁
NN∈F₁→NN∈F F (inj₂ N) (inj₂ N') NN'∈F₁ = NN'∈F₁

morph→morph₁ : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → (P : IdTyCons ⊎ TyCons₁)
             → ( (N N' : IdTyCons ⊎ TyCons₁ ⊎ TyCons₂) 
               → (N , N') ∈ F
               → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ mTyCon₁ P )
             → ( (N N' : IdTyCons ⊎ TyCons₁) 
               → (N , N') ∈ F→F₁ F
               → B[ N , N' ] pm₁ ▷ P )
morph→morph₁ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F₁ = morph₁ idTC idTC NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₂ P) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F₁ = morph₁ idTC idTC NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F₁ = morph₁ idTC (i₂i₁ N') NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₂ P) morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F₁ = morph₁ idTC (i₂i₁ N') NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F₁ = morph₁ (i₂i₁ N) idTC NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₂ P) morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F₁ = morph₁ (i₂i₁ N) idTC NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₂ N) (inj₂ N') NN'∈F₁ = morph₁ (i₂i₁ N) (i₂i₁ N') NN'∈F₁
morph→morph₁ upm₁ upm₂ F (inj₂ P) morph₁ (inj₂ N) (inj₂ N') NN'∈F₁ = morph₁ (i₂i₁ N) (i₂i₁ N') NN'∈F₁

morph→morph₂ : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → (P : IdTyCons ⊎ TyCons₂)
             → ( (N N' : IdTyCons ⊎ TyCons₁ ⊎ TyCons₂) 
               → (N , N') ∈ F
               → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ mTyCon₂ P )
             → ( (N N' : IdTyCons ⊎ TyCons₂) 
               → (N , N') ∈ F→F₂ F
               → B[ N , N' ] pm₂ ▷ P )
morph→morph₂ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F₂ 
  = subst (λ X → X) (sym (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁)))) (morph₁ idTC idTC NN'∈F₂)
morph→morph₂ upm₁ upm₂ F (inj₂ P) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F₂ = morph₁ idTC idTC NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F₂ = morph₁ idTC (i₂i₂ N') NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₂ P) morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F₂ = morph₁ idTC (i₂i₂ N') NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F₂ = morph₁ (i₂i₂ N) idTC NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₂ P) morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F₂ = morph₁ (i₂i₂ N) idTC NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₁ IdentTC) morph₁ (inj₂ N) (inj₂ N') NN'∈F₂ = morph₁ (i₂i₂ N) (i₂i₂ N') NN'∈F₂
morph→morph₂ upm₁ upm₂ F (inj₂ P) morph₁ (inj₂ N) (inj₂ N') NN'∈F₂ = morph₁ (i₂i₂ N) (i₂i₂ N') NN'∈F₂

morph₁→morph : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₁ : IdTyCons ⊎ TyCons₁) → ∃ λ(M₁' : IdTyCons ⊎ TyCons₁) 
               → (M ≡ mTyCon₁ M₁) × (M' ≡ mTyCon₁ M₁') ) 
             → (P : IdTyCons ⊎ TyCons₁)
             → ( (N N' : IdTyCons ⊎ TyCons₁) 
               → (N , N') ∈ F→F₁ F
               → B[ N , N' ] pm₁ ▷ P )
             → ( (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (N , N') ∈ F
               → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ mTyCon₁ P )
morph₁→morph upm₁ upm₂ F pairIn1 (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F = morph₁ idTC idTC NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph₁ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F = morph₁ idTC idTC NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₁ IdentTC) morph₁ (inj₁ IdentTC) (inj₂ (inj₁ N')) NN'∈F = morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph₁ (inj₁ IdentTC) (inj₂ (inj₁ N')) NN'∈F = morph₁ (inj₁ IdentTC) (inj₂ N') NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 P morph₁ (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F = ⊥-elim (pairIn1→⊥ F pairIn1 idTC (i₂i₂ N') NN'∈F (N' , inj₂ refl))
morph₁→morph upm₁ upm₂ F pairIn1 (inj₁ IdentTC) morph₁ (inj₂ (inj₁ N)) (inj₁ IdentTC) NN'∈F = morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph₁ (inj₂ (inj₁ N)) (inj₁ IdentTC) NN'∈F = morph₁ (inj₂ N) (inj₁ IdentTC) NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₁ IdentTC) morph₁ (inj₂ (inj₁ N)) (inj₂ (inj₁ N')) NN'∈F = morph₁ (inj₂ N) (inj₂ N') NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph₁ (inj₂ (inj₁ N)) (inj₂ (inj₁ N')) NN'∈F = morph₁ (inj₂ N) (inj₂ N') NN'∈F
morph₁→morph upm₁ upm₂ F pairIn1 P morph₁ (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F = ⊥-elim (pairIn1→⊥ F pairIn1 (i₂i₁ N) (i₂i₂ N') NN'∈F (N' , inj₂ refl))
morph₁→morph upm₁ upm₂ F pairIn1 P morph₁ (inj₂ (inj₂ N)) N' NN'∈F = ⊥-elim (pairIn1→⊥ F pairIn1 (i₂i₂ N) N' NN'∈F (N , inj₁ refl))

morph₂→morph : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₂ : IdTyCons ⊎ TyCons₂) → ∃ λ(M₂' : IdTyCons ⊎ TyCons₂) 
               → (M ≡ mTyCon₂ M₂) × (M' ≡ mTyCon₂ M₂') ) 
             → (P : IdTyCons ⊎ TyCons₂)
             → ( (N N' : IdTyCons ⊎ TyCons₂) 
               → (N , N') ∈ F→F₂ F
               → B[ N , N' ] pm₂ ▷ P )
             → ( (N N' : IdTyCons ⊎ TyCons₁ ⊎ TyCons₂) 
               → (N , N') ∈ F
               → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ mTyCon₂ P )
morph₂→morph upm₁ upm₂ F pairIn2 (inj₁ IdentTC) morph₂ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F 
  = subst (λ X → X) (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁))) (morph₂ idTC idTC NN'∈F)
morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ P) morph₂ (inj₁ IdentTC) (inj₁ IdentTC) NN'∈F = morph₂ idTC idTC NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 P morph₂ (inj₁ IdentTC) (inj₂ (inj₁ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 idTC (i₂i₁ N') NN'∈F (N' , inj₂ refl))
morph₂→morph upm₁ upm₂ F pairIn2 (inj₁ IdentTC) morph₂ (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F = morph₂ idTC (inj₂ N') NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ P) morph₂ (inj₁ IdentTC) (inj₂ (inj₂ N')) NN'∈F = morph₂ idTC (inj₂ N') NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 P morph₂ (inj₂ (inj₁ N)) (inj₁ IdentTC) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₁ N) idTC NN'∈F (N , inj₁ refl))
morph₂→morph upm₁ upm₂ F pairIn2 P morph₂ (inj₂ (inj₁ N)) (inj₂ (inj₁ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₁ N) (i₂i₁ N') NN'∈F (N , inj₁ refl))
morph₂→morph upm₁ upm₂ F pairIn2 P morph₂ (inj₂ (inj₁ N)) (inj₂ (inj₂ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₁ N) (i₂i₂ N') NN'∈F (N , inj₁ refl))
morph₂→morph upm₁ upm₂ F pairIn2 (inj₁ IdentTC) morph₂ (inj₂ (inj₂ N)) (inj₁ IdentTC) NN'∈F = morph₂ (inj₂ N) idTC NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ P) morph₂ (inj₂ (inj₂ N)) (inj₁ IdentTC) NN'∈F = morph₂ (inj₂ N) idTC NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 P morph₂ (inj₂ (inj₂ N)) (inj₂ (inj₁ N')) NN'∈F = ⊥-elim (pairIn2→⊥ F pairIn2 (i₂i₂ N) (i₂i₁ N') NN'∈F (N' , inj₂ refl))
morph₂→morph upm₁ upm₂ F pairIn2 (inj₁ IdentTC) morph₂ (inj₂ (inj₂ N)) (inj₂ (inj₂ N')) NN'∈F = morph₂ (inj₂ N) (inj₂ N') NN'∈F
morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ P) morph₂ (inj₂ (inj₂ N)) (inj₂ (inj₂ N')) NN'∈F = morph₂ (inj₂ N) (inj₂ N') NN'∈F

princ₁→princ : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₁ : IdTyCons ⊎ TyCons₁) → ∃ λ(M₁' : IdTyCons ⊎ TyCons₁) 
               → (M ≡ mTyCon₁ M₁) × (M' ≡ mTyCon₁ M₁') )
             → (M₁ M₂ : IdTyCons ⊎ TyCons₁)
             → ( ∃ λ(M̂ : IdTyCons ⊎ TyCons₁) 
                 → B[ M̂ , idTC ] pm₁ ▷ M₁ 
                 × B[ M̂ , idTC ] pm₁ ▷ M₂ 
                 × ( (N N' : IdTyCons ⊎ TyCons₁) → (N , N') ∈ F→F₁ F → B[ N , N' ] pm₁ ▷ M̂ ) )
             → ( ∃ λ(M̂ : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
                 → B[ M̂ , idTC ] polymonadUnion upm₁ upm₂ ▷ mTyCon₁ M₁ 
                 × B[ M̂ , idTC ] polymonadUnion upm₁ upm₂ ▷ mTyCon₁ M₂ 
                 × ( (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) → (N , N') ∈ F → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ M̂ ) )
princ₁→princ upm₁ upm₂ F pairIn1 (inj₁ IdentTC) (inj₁ IdentTC) (inj₁ IdentTC , b₁ , b₂ , morph) = idTC , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 idTC morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₁ IdentTC) (inj₁ IdentTC) (inj₂ P , b₁ , b₂ , morph) = i₂i₁ P , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₁ IdentTC) (inj₂ N') (inj₁ IdentTC , b₁ , b₂ , morph) = idTC , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 idTC morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₁ IdentTC) (inj₂ N') (inj₂ P , b₁ , b₂ , morph) = i₂i₁ P , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₂ N) (inj₁ IdentTC) (inj₁ IdentTC , b₁ , b₂ , morph) = idTC , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 idTC morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₂ N) (inj₁ IdentTC) (inj₂ P , b₁ , b₂ , morph) = i₂i₁ P , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph
princ₁→princ upm₁ upm₂ F pairIn1 (inj₂ N) (inj₂ N') (inj₁ IdentTC , b₁ , b₂ , morph) = idTC , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 idTC morph 
princ₁→princ upm₁ upm₂ F pairIn1 (inj₂ N) (inj₂ N') (inj₂ P , b₁ , b₂ , morph) = i₂i₁ P , b₁ , b₂ , morph₁→morph upm₁ upm₂ F pairIn1 (inj₂ P) morph

princ₂→princ : ∀ {TyCons₁ TyCons₂ : Set}
             → {pm₁ : Polymonad (IdTyCons ⊎ TyCons₁) idTC}
             → {pm₂ : Polymonad (IdTyCons ⊎ TyCons₂) idTC}
             → (upm₁ : UnionablePolymonad pm₁)
             → (upm₂ : UnionablePolymonad pm₂)
             → (F : SubsetOf ( (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) × (IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) ))
             → ( ∀ (M M' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
               → (M , M') ∈ F 
               → ∃ λ(M₂ : IdTyCons ⊎ TyCons₂) → ∃ λ(M₂' : IdTyCons ⊎ TyCons₂) 
               → (M ≡ mTyCon₂ M₂) × (M' ≡ mTyCon₂ M₂') )
             → (M₁ M₂ : IdTyCons ⊎ TyCons₂)
             → ( ∃ λ(M̂ : IdTyCons ⊎ TyCons₂) 
                 → B[ M̂ , idTC ] pm₂ ▷ M₁ 
                 × B[ M̂ , idTC ] pm₂ ▷ M₂ 
                 × ( (N N' : IdTyCons ⊎ TyCons₂) → (N , N') ∈ F→F₂ F → B[ N , N' ] pm₂ ▷ M̂ ) )
             → ( ∃ λ(M̂ : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) 
                 → B[ M̂ , idTC ] polymonadUnion upm₁ upm₂ ▷ mTyCon₂ M₁ 
                 × B[ M̂ , idTC ] polymonadUnion upm₁ upm₂ ▷ mTyCon₂ M₂ 
                 × ( (N N' : IdTyCons ⊎ (TyCons₁ ⊎ TyCons₂)) → (N , N') ∈ F → B[ N , N' ] polymonadUnion upm₁ upm₂ ▷ M̂ ) )
princ₂→princ upm₁ upm₂ F pairIn2 (inj₁ IdentTC) (inj₁ IdentTC) (inj₁ IdentTC , b₁ , b₂ , morph) 
  = idTC , 
    subst (λ X → X) (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁))) b₁ , 
    subst (λ X → X) (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁))) b₂ , 
    morph₂→morph upm₁ upm₂ F pairIn2 idTC morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₁ IdentTC) (inj₁ IdentTC) (inj₂ M̂ , b₁ , b₂ , morph) 
  = i₂i₂ M̂ , b₁ , b₂ , morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ M̂) morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₁ IdentTC) (inj₂ M₂) (inj₁ IdentTC , b₁ , b₂ , morph) 
  = idTC , 
    subst (λ X → X) (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁))) b₁ , 
    b₂ ,  morph₂→morph upm₁ upm₂ F pairIn2 idTC morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₁ IdentTC) (inj₂ M₂) (inj₂ M̂ , b₁ , b₂ , morph) 
  = i₂i₂ M̂ , b₁ , b₂ , (morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ M̂) morph)
princ₂→princ upm₁ upm₂ F pairIn2 (inj₂ M₁) (inj₁ IdentTC) (inj₁ IdentTC , b₁ , b₂ , morph) 
  = idTC , b₁ , 
    subst (λ X → X) (trans (UnionablePolymonad.lawEqIdBinds upm₂) (sym (UnionablePolymonad.lawEqIdBinds upm₁))) b₂ , 
    morph₂→morph upm₁ upm₂ F pairIn2 idTC morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₂ M₁) (inj₁ IdentTC) (inj₂ M̂ , b₁ , b₂ , morph) 
  = i₂i₂ M̂ , b₁ , b₂ , morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ M̂) morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₂ M₁) (inj₂ M₂) (inj₁ IdentTC , b₁ , b₂ , morph) 
  = idTC , b₁ , b₂ , morph₂→morph upm₁ upm₂ F pairIn2 idTC morph
princ₂→princ upm₁ upm₂ F pairIn2 (inj₂ M₁) (inj₂ M₂) (inj₂ M̂ , b₁ , b₂ , morph) 
  = i₂i₂ M̂ , b₁ , b₂ , morph₂→morph upm₁ upm₂ F pairIn2 (inj₂ M̂) morph
