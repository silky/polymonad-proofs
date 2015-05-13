 
module Polymonad.Principal where

-- Stdlib
open import Data.Product
open import Data.Sum
open import Data.Bool
open import Relation.Nullary.Core
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

-- Local
open import Haskell
open import Polymonad
open import Identity

SubsetOf : Type → Set
SubsetOf X = X → Bool

_∈_ : ∀ {X : Type} → (x : X) → (S : SubsetOf X) → Set
x ∈ S = S x ≡ true

_∈?_ : ∀ {X : Type} → (x : X) → (S : SubsetOf X) → Dec (S x ≡ true)
x ∈? S = S x ≟ true

PrincipalPM : ∀ {TyCons : Set} {Id : TyCons} →  Polymonad TyCons Id → Set
PrincipalPM {TyCons} {Id} pm 
  = (F : SubsetOf (TyCons × TyCons))
  → (M₁ M₂ : TyCons)
  → (∀ (M M' : TyCons) → (M , M') ∈ F → B[ M , M' ] pm ▷ M₁)
  → (∀ (M M' : TyCons) → (M , M') ∈ F → B[ M , M' ] pm ▷ M₂)
  → ∃ λ(M̂ : TyCons) 
  → B[ M̂ , Id ] pm ▷ M₁ 
  × B[ M̂ , Id ] pm ▷ M₂ 
  × (∀ (M M' : TyCons) → (M , M') ∈ F → B[ M , M' ] pm ▷ M̂)

