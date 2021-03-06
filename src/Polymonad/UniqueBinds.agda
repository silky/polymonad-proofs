 
module Polymonad.UniqueBinds where

-- Stdlib
open import Data.Product
open import Data.Sum
open import Data.Bool
open import Relation.Nullary
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

-- Local
open import Extensionality
open import Haskell
open import Polymonad.Definition
open import Identity
open import Utilities

-- Records
open Polymonad

-- -----------------------------------------------------------------------------
-- Bind operators are unique
-- -----------------------------------------------------------------------------

-- If there are potentially different instances of a bind operator,
-- we can show that their operational behaviour is the same.
uniqueBind : ∀ {TyCons : Set} {Id : TyCons} 
           → (pm : Polymonad TyCons Id) 
           → (M N P : TyCons) 
           → (b₁ : B[ M , N ] pm ▷ P) 
           → (b₂ : B[ M , N ] pm ▷ P)
           → ∀ {α β} → bind pm b₁ {α} {β} ≡ bind pm b₂ {α} {β}
uniqueBind {TyCons = TyCons} {Id = Id} pm M N P b₁ b₂ = fun-ext₂ proof
  where
    law-id' = law-id pm

    proof' : (M N S R T : TyCons) 
           → (b₁ b₂ : B[ N , R ] pm ▷ S)
           → (b₁' b₂' : B[ M , S ] pm ▷ T) 
           → ∀ {α β γ} → (m : ⟨ pm ▷ M ⟩ α) (f : α → ⟨ pm ▷ N ⟩ β) (g : β → ⟨ pm ▷ R ⟩ γ)
           → (bind pm b₁') m (λ x → (bind pm b₁) (f x) g) ≡ (bind pm b₂') m (λ x → (bind pm b₂) (f x) g)
    proof' M N S R T b₁ b₂ b₁' b₂' m f g = 
      let
        P , b₃ , b₄ = lawDiamond2 pm M N R T (S , b₁ , b₁')
      in begin
        (bind pm b₁') m (λ x → (bind pm b₁) (f x) g)
          ≡⟨ sym (law-assoc pm M N P R T S b₃ b₄ b₁ b₁' m f g) ⟩
        (bind pm b₄) ((bind pm b₃) m f) g
          ≡⟨ law-assoc pm M N P R T S b₃ b₄ b₂ b₂' m f g ⟩
        (bind pm b₂') m (λ x → (bind pm b₂) (f x) g) ∎
    
    mkFunctor : (N : TyCons) → B[ N , Id ] pm ▷ N
    mkFunctor N = lawFunctor1 pm N
    
    functionAsFunctor : {α β : Type} → (N : TyCons) → (f : α → ⟨ pm ▷ N ⟩ β) → f ≡ (λ y → (bind pm (mkFunctor N)) (f y) (id law-id'))
    functionAsFunctor N f = let q = lawFunctor2 pm N (lawFunctor1 pm N) in fun-ext (λ x → sym (q (f x)))
    
    proof : ∀ {α β} 
          → (x : ⟨ pm ▷ M ⟩ α) → (f : α → ⟨ pm ▷ N ⟩ β)
          → bind pm b₁ x f ≡ bind pm b₂ x f
    proof x f = begin
      bind pm b₁ x f
        ≡⟨ cong (λ X → bind pm b₁ x X) (functionAsFunctor N f) ⟩
      bind pm b₁ x (λ y → (bind pm (mkFunctor N)) (f y) (id law-id'))
        ≡⟨ proof' M N N Id P (mkFunctor N) (mkFunctor N) b₁ b₂ x f (id law-id') ⟩
      bind pm b₂ x (λ y → (bind pm (mkFunctor N)) (f y) (id law-id'))
        ≡⟨ sym (cong (λ X → bind pm b₂ x X) (functionAsFunctor N f)) ⟩
      bind pm b₂ x f ∎

-- -----------------------------------------------------------------------------
-- Uniqueness Lemmas
-- -----------------------------------------------------------------------------

-- All application bind operators have the same operational behaviour.
uniqueApply : ∀ {TyCons : Set} {Id : TyCons} 
              → (pm : Polymonad TyCons Id) 
              → (M : TyCons) 
              → (b₁ : B[ Id , M ] pm ▷ M) 
              → (b₂ : B[ Id , M ] pm ▷ M)
              → ∀ {α β} → bind pm b₁ {α} {β} ≡ bind pm b₂ {α} {β}
uniqueApply {Id = Id} pm M b₁ b₂ = uniqueBind pm Id M M b₁ b₂

-- All functor bind operators have the same operational behaviour.
uniqueFunctor : ∀ {TyCons : Set} {Id : TyCons} 
              → (pm : Polymonad TyCons Id) 
              → (M : TyCons) 
              → (b₁ : B[ M , Id ] pm ▷ M) 
              → (b₂ : B[ M , Id ] pm ▷ M)
              → ∀ {α β} → bind pm b₁ {α} {β} ≡ bind pm b₂ {α} {β}
uniqueFunctor {Id = Id} pm M b₁ b₂ = uniqueBind pm M Id M b₁ b₂

-- All return bind operators have the same operational behaviour.
uniqueReturn : ∀ {TyCons : Set} {Id : TyCons} 
             → (pm : Polymonad TyCons Id) 
             → (M : TyCons) 
             → (b₁ : B[ Id , Id ] pm ▷ M) 
             → (b₂ : B[ Id , Id ] pm ▷ M)
             → ∀ {α β} → bind pm b₁ {α} {β} ≡ bind pm b₂ {α} {β}
uniqueReturn {Id = Id} pm M b₁ b₂ = uniqueBind pm Id Id M b₁ b₂
