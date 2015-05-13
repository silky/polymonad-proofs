
module Utilities where

-- Stdlib
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Relation.Nullary.Core -- ¬
open import Relation.Binary.PropositionalEquality -- ≡
open ≡-Reasoning

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

cong₃ : ∀ {a b c d} {A : Set a} {B : Set b} {C : Set c}
        (f : A → B → C → Set d) {x y u v r s} 
      → x ≡ y → u ≡ v → r ≡ s 
      → f x u r ≡ f y v s
cong₃ f refl refl refl = refl

subst₃ : ∀ {a b c d} {A : Set a} {B : Set b} {C : Set c} 
         (P : A → B → C → Set d) {x₁ x₂ y₁ y₂ z₁ z₂} 
       → x₁ ≡ x₂ → y₁ ≡ y₂ → z₁ ≡ z₂ → P x₁ y₁ z₁ → P x₂ y₂ z₂
subst₃ P refl refl refl p = p

-- If two type functions are equivalent, then applying them to the same value 
-- delivers equivalent results.
funCong : ∀ {a : Set} {f g : Set → Set} → f ≡ g → f a ≡ g a
funCong {a} {f} {g} fg = cong (λ h → h a) fg

funCong₂ : ∀ {A B C : Set} {a : A} {b : B} {f g : A → B → C} → f ≡ g → f a b ≡ g a b
funCong₂ {a = a} {b} {f} {g} fg = cong (λ h → h a b) fg

-- We can assume function extensionality is true, because we are modelling
-- and proving things for Haskell.
postulate
  funExt : ∀ {l k} {A : Set l} {B : A → Set k} {f g : (a : A) → B a} → ((x : A) → f x ≡ g x) → f ≡ g

funExt₂ : ∀ {l k n} {A : Set l} {B : A → Set k} {C : (a : A) → B a → Set n} {f g : (a : A) → (b : B a) → C a b} → ((a : A) → (b : B a) → f a b ≡ g a b) → f ≡ g
funExt₂ {f = f} {g = g} p = funExt (λ a → funExt (p a))

-- The laws involving the existance of certains bind operators 
-- are simplified using the curry-howard correspondance:
-- ∃ λ A → ⊤   ⇔   A
-- (a , tt)    ⇔   a
-- and
-- ∃ λ A → ∃ λ B → ⊤   ⇔   A × B
-- (a, (b, tt))        ⇔   a , b
curry-∃→ : ∀ {A : Set} → (∃ λ A → ⊤) → A
curry-∃→ (a , tt) = a

curry-∃← : ∀ {A : Set} → A → (∃ λ A → ⊤)
curry-∃← a = a , tt

curry-∃∃→ : ∀ {A B : Set} → (∃ λ A → ∃ λ B → ⊤) → A × B
curry-∃∃→ (a , (b , tt)) = a , b

curry-∃∃← : ∀ {A B : Set} → A × B → (∃ λ A → ∃ λ B → ⊤)
curry-∃∃← (a , b) = (a , (b , tt))

-- Equivalence of negation of existence and forall.
¬∃→∀¬ : (A : Set) → (P : A → Set) → ¬ (∃ λ(a : A) → P a) → (∀ (a : A) → ¬ P a)
¬∃→∀¬ A P p a pa = p (a , pa)

∀¬→¬∃ : (A : Set) → (P : A → Set) → (∀ (a : A) → ¬ P a) → ¬ (∃ λ(a : A) → P a)
∀¬→¬∃ A P p (a , pa) = p a pa

--------------------------------------------------------------------------------
-- Bijections
--------------------------------------------------------------------------------

-- Bijections
record _↔_ (A : Set) (B : Set) : Set where
  field
    f   : A → B
    f⁻¹ : B → A
    lawf⁻¹f : ∀ {x : A} → f⁻¹ (f x) ≡ x
    lawff⁻¹ : ∀ {x : B} → f (f⁻¹ x) ≡ x

