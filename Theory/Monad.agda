
module Theory.Monad where

-- Stdlib
open import Level
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning 

-- Local
open import Theory.Category
open import Theory.Functor
open import Theory.NaturalTransformation

open Category

record Monad {ℓ : Level} {C : Category {ℓ = ℓ}} (M : Functor C C) : Set ℓ where
  field
    η : NaturalTransformation Id[ C ]     M
    μ : NaturalTransformation [ M ]∘[ M ] M
    
    μCoher : {x : Obj C}
           → _∘_ C (η⟨ μ ⟩ x) ([ M ]₁ (η⟨ μ ⟩ x)) ≡ _∘_ C (η⟨ μ ⟩ x) (η⟨ μ ⟩ ([ M ]₀ x))
           -- μ ∘ Tμ ≡ μ ∘ μT

    ηCoherL : {x : Obj C}
            → _∘_ C (η⟨ μ ⟩ x) ([ M ]₁ (η⟨ η ⟩ x)) ≡ η⟨ Id⟨ M ⟩ ⟩ x
            -- μ ∘ Tη ≡ 1ₜ
    
    ηCoherR : {x : Obj C}
            → _∘_ C (η⟨ μ ⟩ x) (η⟨ η ⟩ ([ M ]₀ x)) ≡ η⟨ Id⟨ M ⟩ ⟩ x
            -- μ ∘ ηT ≡ 1ₜ

idMonad : {ℓ : Level} {C : Category {ℓ = ℓ}} → Monad (Id[ C ])
idMonad {C = C} = record 
  { η = Id⟨ Id[ C ] ⟩
  ; μ = Id⟨ Id[ C ] ⟩
  ; μCoher = refl
  ; ηCoherL = Category.idR C
  ; ηCoherR = Category.idL C
  }

