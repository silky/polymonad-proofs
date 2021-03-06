 
module Theory.Monoid where

-- Stdlib
open import Level
open import Agda.Primitive
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning 

-- Local
open import Theory.Category


record Monoid {ℓ} (C : Set ℓ) : Set ℓ where
  field
    ε : C
    _∙_ : C → C → C
    
    right-id : {m : C} → m ∙ ε ≡ m
    left-id : {m : C} → ε ∙ m ≡ m
    assoc : {m n o : C} → m ∙ (n ∙ o) ≡ (m ∙ n) ∙ o
  
  carrier : Set ℓ
  carrier = C

Monoid→Category : ∀ {ℓ} {C : Set ℓ} → Monoid C → Category {ℓ₀ = ℓ}
Monoid→Category {ℓ = ℓ} monoid = record
  { Obj = Lift ⊤
  ; Hom = \_ _ → Monoid.carrier monoid
  ; _∘_ = Monoid._∙_ monoid
  ; id = Monoid.ε monoid
  ; assoc = Monoid.assoc monoid
  ; left-id = Monoid.right-id monoid
  ; right-id = Monoid.left-id monoid
  }
    
