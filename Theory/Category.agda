
module Theory.Category where

-- Stdlib
open import Agda.Primitive
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

record Category {ℓ : Level} : Set (lsuc ℓ) where
  field
    Obj : Set ℓ
    Hom : Obj → Obj → Set ℓ
    
    _∘_ : ∀ {a b c} → Hom b c → Hom a b → Hom a c
    id : ∀ {a} → Hom a a
    
    assoc : {a b c d : Obj} {f : Hom a b} {g : Hom b c} {h : Hom c d} 
          → h ∘ (g ∘ f) ≡ (h ∘ g) ∘ f
    idL : {a b : Obj} {f : Hom a b} → id ∘ f ≡ f
    idR : {a b : Obj} {f : Hom a b} → f ∘ id ≡ f