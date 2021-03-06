
open import Level
open import Function hiding ( id ) renaming ( _∘_ to _∘F_)

open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

open import Extensionality
open import Bijection using ( Bijection ; _↔_ )

open import Theory.Category
open import Theory.Category.Examples
open import Theory.Functor
open import Theory.Natural.Transformation

module Theory.Yoneda.Bijection {ℓ₀ ℓ₁ : Level} {C : Category {ℓ₀} {ℓ₁}} where

open Category
open Functor hiding ( id )
open NaturalTransformation

private
  SetCat = setCategory {ℓ₁}
  _∘C_ = _∘_ C
  _∘Set_ = _∘_ SetCat

import Theory.Yoneda.HomFunctor
open Theory.Yoneda.HomFunctor {ℓ₀} {ℓ₁} {C}

yoneda→ : (F : Functor C SetCat) → (A : Obj C) → NaturalTransformation Hom[ A ,-] F → [ F ]₀ A
yoneda→ F A (naturalTransformation η natural) = η A (id C {A})

yoneda← : (F : Functor C SetCat) → (A : Obj C) → [ F ]₀ A → NaturalTransformation Hom[ A ,-] F
yoneda← F A FA = naturalTransformation η' natural-η
  where
    η' : (x : Obj C) → Hom SetCat ([ Hom[ A ,-] ]₀ x) ([ F ]₀ x)
    η' x f = (F₁ F f) FA
    
    -- h A f = λ g → f ∘C g
    natural-η : {a b : Obj C} {f : Hom C a b} → ([ F ]₁ f) ∘Set (η' a) ≡ (η' b) ∘Set ([ Hom[ A ,-] ]₁ f)
    natural-η {a} {b} {f} = begin
      ([ F ]₁ f) ∘Set (η' a) 
        ≡⟨ refl ⟩
      ( λ g → ([ F ]₁ f) (([ F ]₁ g) FA) )
        ≡⟨ fun-ext (λ g → cong (λ P → P FA) (sym $ compose F)) ⟩
      ( λ g → ([ F ]₁ (f ∘C g)) FA )
        ≡⟨ refl ⟩
      (η' b) ∘Set ([ Hom[ A ,-] ]₁ f) ∎

yoneda-right-id : (F : Functor C SetCat) → (A : Obj C) → yoneda→ F A ∘F yoneda← F A ≡ (λ x → x)
yoneda-right-id F A = fun-ext p
  where
    p : (FA : F₀ F A) → (yoneda→ F A ∘F yoneda← F A) FA ≡ FA
    p FA with yoneda← F A FA 
    p FA | naturalTransformation η natural = begin
      F₁ F (id C) FA 
        ≡⟨ cong (λ P → P FA) (Functor.id F) ⟩
      FA ∎

yoneda-left-id : (F : Functor C SetCat) → (A : Obj C) → yoneda← F A ∘F yoneda→ F A ≡ (λ x → x)
yoneda-left-id F A = fun-ext $ λ NatTrans → natural-transformation-eq (p NatTrans)
  where
    open NaturalTransformation
    
    p : (NatTrans : NaturalTransformation Hom[ A ,-] F) → η (yoneda← F A (yoneda→ F A NatTrans)) ≡ η NatTrans
    p (naturalTransformation η' natural) = fun-ext $ λ x → fun-ext $ λ f → begin
      η (yoneda← F A (yoneda→ F A (naturalTransformation η' natural))) x f
        ≡⟨ refl ⟩
      ([ F ]₁ f ∘Set η' A) (id C {A})
        ≡⟨ cong (λ P → P (id C {A})) (natural {A} {x} {f}) ⟩
      (η' x ∘Set ([ Hom[ A ,-] ]₁ f)) (id C {A})
        ≡⟨ refl ⟩
      η' x (f ∘C (id C {A}))
        ≡⟨ cong (η' x) (left-id C) ⟩
      η' x f ∎

yoneda-bijection : (F : Functor C SetCat) → (A : Obj C) → NaturalTransformation Hom[ A ,-] F ↔ [ F ]₀ A
yoneda-bijection F A = record
  { f = yoneda→ F A
  ; inv = yoneda← F A
  ; left-id = λ a → cong (λ f → f a) (yoneda-left-id F A)
  ; right-id = λ b → cong (λ f → f b) (yoneda-right-id F A)
  }

