
module Polymonad.HicksPolymonad where

-- Stdlib
open import Agda.Primitive
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

-- Local
open import Utilities
open import Haskell
open import Identity
    
--------------------------------------------------------------------------------
-- Polymonad Definition
--------------------------------------------------------------------------------

-- Polymonads as defined in the paper by Hicks et al. (2014)
record HicksPolymonad {l : Level} (TyCons : Set l) (Id : TyCons) : Set (lsuc l) where
  field
    -- Set of bind operator names for each combination of type constructors
    B[_,_]▷_ : (M N P : TyCons) → Set l

    -- Interpretation of type constructor names into actual type constructors
    ⟨_⟩ : TyCons → TyCon
    
    -- Interpretation of bind operator names into actual bind-operations
    bind : {M N P : TyCons} → B[ M , N ]▷ P → [ ⟨ M ⟩ , ⟨ N ⟩ ]▷ ⟨ P ⟩
    
    -- Law of the Id type constructor: Id τ = τ
    lawId : ⟨ Id ⟩ ≡ Identity
    
    -- Functor law from the definition:
    lawFunctor : ∀ (M : TyCons) → ∃ λ(b : B[ M , Id ]▷ M) 
               → ∀ {α : Type} (m : ⟨ M ⟩ α) → (bind b) m (id lawId) ≡ m
    
    -- Paired morphism law from the definition:
    -- ∃ b₁:(M,Id)▷N ∈ Σ ⇔ ∃ b₂:(Id,M)▷N ∈ Σ
    -- and ∀ b₁:(M,Id)▷N, b₂:(Id,M)▷N . b₁ (f v) (λy.y) = b₂ v f

    -- Left to right direction of the paired morphism law equivalancy:
    lawMorph1 : ∀ (M N : TyCons) 
              → (B[ M , Id ]▷ N → B[ Id , M ]▷ N)
    -- Right to left direction of the paired morphism law equivalancy:
    lawMorph2 : ∀ (M N : TyCons) 
              → (B[ Id , M ]▷ N → B[ M , Id ]▷ N)
    -- Equation of the paired morphism law:
    lawMorph3 : ∀ (M N : TyCons) (b₁ : B[ M , Id ]▷ N) (b₂ : B[ Id , M ]▷ N)
              → ∀ {α β : Type} (v : α) (f : α → ⟨ M ⟩ β) 
              → (bind b₁) (f v) (id lawId) ≡ (bind b₂) ((id lawId) v) f
    
    -- Diamond law from the definition:
    -- ( ∃ P, b₁, b₂ . { b₁:(M,N)▷P, b₂:(P,R)▷T } ⊆ Σ ) ⇔
    -- ( ∃ S, b₃, b₄ . { b₃:(N,R)▷S, b₄:(M,S)▷T } ⊆ Σ )
    
    -- Left to right direction of the diamond law equivalancy:
    lawDiamond1 : ∀ (M N R T : TyCons)
                → (∃ λ(P : TyCons) → B[ M , N ]▷ P × B[ P , R ]▷ T)
                → (∃ λ(S : TyCons) → B[ N , R ]▷ S × B[ M , S ]▷ T)
    -- Right to left direction of the diamond law equivalancy:
    lawDiamond2 : ∀ (M N R T : TyCons)
                → (∃ λ(S : TyCons) → B[ N , R ]▷ S × B[ M , S ]▷ T)
                → (∃ λ(P : TyCons) → B[ M , N ]▷ P × B[ P , R ]▷ T)
    
    -- Associativity law from the definition:
    -- ∀ b₁, b₂, b₃, b₄ . 
    -- "If" { b₁:(M,N)▷P, b₂:(P,R)▷T, b₃:(N,R)▷S, b₄:(M,S)▷T } ⊆ Σ
    -- "then" b₂ (b₁ m f) g = b₄ m (λ x . b₃ (f x) g)
    lawAssoc : ∀ (M N P R T S : TyCons) 
             → (b₁ : B[ M , N ]▷ P) → (b₂ : B[ P , R ]▷ T) 
             → (b₃ : B[ N , R ]▷ S) → (b₄ : B[ M , S ]▷ T)
             → ∀ {α β γ : Type} (m : ⟨ M ⟩ α) (f : α → ⟨ N ⟩ β) (g : β → ⟨ R ⟩ γ)
             → (bind b₂) ((bind b₁) m f) g ≡ (bind b₄) m (λ x → (bind b₃) (f x) g)
    
    -- Closure law from the definition:
    -- "If" ∃ b₁, b₂, b₃, b₄ .
    -- { b₁:(M,N)▷P, b₂:(S,Id)▷M, b₃:(T,Id)▷N, b₄:(P,Id)▷U } ⊆ Σ
    -- "then" ∃ b . b:(S,T)▷U ∈ Σ
    lawClosure : ∀ (M N P S T U : TyCons)
               → ( B[ M , N ]▷ P × B[ S , Id ]▷ M × B[ T , Id ]▷ N × B[ P , Id ]▷ U )
               → B[ S , T ]▷ U

  pmId : TyCons
  pmId = Id

