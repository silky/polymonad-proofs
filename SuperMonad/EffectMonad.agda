
module SuperMonad.EffectMonad where

-- Stdlib
open import Level
open import Function
open import Agda.Primitive
open import Data.Product
open import Data.Sum
open import Data.Unit
open import Data.Empty
open import Data.Nat
open import Data.Vec hiding ( _>>=_ )
open import Relation.Nullary
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

-- Local
open import Utilities
open import Haskell
open import Identity
open import Functor
open import Polymonad
open import Parameterized.PhantomIndices
open import Parameterized.EffectMonad
open import SuperMonad.Definition
--open import SuperMonad.HaskSuperMonad

open Parameterized.EffectMonad.Monoid

-- -----------------------------------------------------------------------------
-- Indexed Monads are Super Monads
-- -----------------------------------------------------------------------------

EffectMonad→Supermonad : ∀ {n}
                       → (Effect : Set n)
                       → (EffectMonoid : Monoid Effect)
                       → (M : Effect → TyCon)
                       → EffectMonad Effect {{EffectMonoid}} M → Supermonad (EffMonadTyCons Effect)
EffectMonad→Supermonad {n = n} Effect monoid M monad = record
  { ⟨_⟩ = ⟨_⟩
  ; Binds = Binds
  ; Returns = Returns
  ; functor = functor
  ; tyConArity = tyConArity
  ; tyConArgTys = tyConArgTys
  ; tyCon = tyCon
  ; bind = bind
  ; return = return
  ; lawSingleTyCon = lawSingleTyCon
  ; lawUniqueBind = lawUniqueBind
  ; lawUniqueReturn = lawUniqueReturn
  ; lawIdR = lawIdR
  ; lawIdL = lawIdL
  ; lawAssoc = lawAssoc
  ; lawMonadFmap = lawMonadFmap
  } where
    TyCons = EffMonadTyCons Effect

    _∙_ = Monoid._∙_ monoid
    ε = Monoid.ε monoid
    
    ⟨_⟩ : TyCons → TyCon
    ⟨_⟩ (EffMonadTC e) = M e
    
    Binds : TyCons → TyCons → TyCons → Type → Type → Set n
    Binds (EffMonadTC m) (EffMonadTC n) (EffMonadTC p) _ _ = p ≡ m ∙ n 
    
    Returns : TyCons → Type → Set n
    Returns (EffMonadTC m) _ = m ≡ ε

    tyConArity : ℕ
    tyConArity = 1

    tyConArgTys : Vec (Set n) tyConArity
    tyConArgTys = Effect ∷ []
    
    tyCon : ParamTyCon tyConArgTys
    tyCon e = lift $ M e
    
    _>>=_ = EffectMonad._>>=_ monad
    return' = EffectMonad.return monad
    
    bind : {α β : Type} {M N P : TyCons} → Binds M N P α β → ( ⟨ M ⟩ α → (α → ⟨ N ⟩ β) → ⟨ P ⟩ β )
    bind {M = EffMonadTC m} {N = EffMonadTC n} {P = EffMonadTC .(m ∙ n)} refl = _>>=_
    
    return : ∀ {α : Type} → {M : TyCons} → Returns M α → α → ⟨ M ⟩ α
    return {M = EffMonadTC ._} refl = return'
    
    fmap : ∀ {m : Monoid.carrier monoid} {α β : Type} → (α → β) → M m α → M m β
    fmap {m = m} {β = β} f ma = subst₂ M (Monoid.lawIdR monoid m) refl (ma >>= (return' ∘ f))
    
    lawSingleTyCon : ∀ (M : TyCons) 
                   → ∃Indices tyConArgTys tyCon (λ X → Lift {ℓ = lsuc n} (⟨ M ⟩ ≡ X))
    lawSingleTyCon (EffMonadTC m) = m , lift refl
    
    lawUniqueBind : {α β : Type} {M N P : TyCons} 
                  → (b₁ b₂ : Binds M N P α β) 
                  → b₁ ≡ b₂
    lawUniqueBind {M = EffMonadTC m} {N = EffMonadTC n} {P = EffMonadTC .(m ∙ n)} refl refl = refl
    
    lawUniqueReturn : {α : Type} {M : TyCons} 
                    → (r₁ r₂ : Returns M α) 
                    → r₁ ≡ r₂
    lawUniqueReturn {M = EffMonadTC .ε} refl refl = refl
    
    bindEq : {α β : Type} {m n p : Effect}
           → (b : Binds (EffMonadTC m) (EffMonadTC n) (EffMonadTC p) α β)
           → bind b ≡ subst (λ X → [ ⟨ EffMonadTC m ⟩ , ⟨ EffMonadTC n ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b) (_>>=_) {α} {β}
    bindEq refl = refl

    bindSubstShift : {α β : Type} {m n p : Effect}
                   → (b : Binds (EffMonadTC m) (EffMonadTC n) (EffMonadTC p) α β )
                   → (ma : ⟨ EffMonadTC m ⟩ α) → (f : α → ⟨ EffMonadTC n ⟩ β)
                   → subst (λ X → [ ⟨ EffMonadTC m ⟩ , ⟨ EffMonadTC n ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b) (_>>=_) ma f ≡ subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (ma >>= f)
    bindSubstShift refl ma f = refl

    subst₂ToSubst : {α : Type} {m n : Effect}
                  → (eq : m ≡ n)
                  → (ma : ⟨ EffMonadTC m ⟩ α)
                  → subst₂ M eq refl ma ≡ subst (λ X → ⟨ EffMonadTC X ⟩ α) eq ma 
    subst₂ToSubst refl ma = refl
    
    lawIdR : ∀ {α β : Type} 
           → (M N : TyCons)
           → (b : Binds M N N α β) → (r : Returns M α)
           → (a : α) → (k : α → ⟨ N ⟩ β)
           → bind b (return r a) k ≡ k a
    lawIdR {β = β} (EffMonadTC .ε) (EffMonadTC x) b refl a k = begin
      bind b (return' a) k
        ≡⟨ cong (λ X → X (return' a) k) (bindEq b) ⟩
      subst (λ X → [ ⟨ EffMonadTC ε ⟩ , ⟨ EffMonadTC x ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b) (_>>=_) (return' a) k
        ≡⟨ bindSubstShift b (return' a) k ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (return' a >>= k)
        ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) X) (EffectMonad.lawIdL monad a k) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (subst₂ M (sym (Monoid.lawIdL monoid x)) refl (k a))
        ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) X) (subst₂ToSubst (sym (Monoid.lawIdL monoid x)) (k a)) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym (Monoid.lawIdL monoid x)) (k a))
        ≡⟨ cong (λ Y → subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ β) Y (k a))) 
                (proof-irrelevance (sym (Monoid.lawIdL monoid x)) b) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ β) b (k a))
        ≡⟨ subst²≡id' b (λ X → ⟨ EffMonadTC X ⟩ β) (k a) ⟩
      k a ∎

    lawIdL : ∀ {α : Type} 
           → (M N : TyCons)
           → (b : Binds M N M α α) → (r : Returns N α)
           → (m : ⟨ M ⟩ α)
           → bind b m (return r) ≡ m
    lawIdL {α = α} (EffMonadTC e) (EffMonadTC .ε) b refl m = begin
      bind b m return' 
        ≡⟨ cong (λ X → X m return') (bindEq b) ⟩
      subst (λ X → [ ⟨ EffMonadTC e ⟩ , ⟨ EffMonadTC ε ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b) (_>>=_) m return' 
        ≡⟨ bindSubstShift b m return' ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) (m >>= return') 
        ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) X) (EffectMonad.lawIdR monad m) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) (subst₂ M (sym (Monoid.lawIdR monoid e)) refl m) 
        ≡⟨ cong (λ Y → subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) Y) (subst₂ToSubst (sym (Monoid.lawIdR monoid e)) m) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym (Monoid.lawIdR monoid e)) m) 
        ≡⟨ cong (λ Y → subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ α) Y m) ) (proof-irrelevance (sym (Monoid.lawIdR monoid e)) b) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ α) (sym b) (subst (λ X → ⟨ EffMonadTC X ⟩ α) b m) 
        ≡⟨ subst²≡id' b (λ X → ⟨ EffMonadTC X ⟩ α) m ⟩
      m ∎
    
    assocSubstShift : {α β : Type} {m n p s : Effect}
                    → (assoc : m ∙ n ≡ p)
                    → (inner : m ≡ s)
                    → (outer : s ∙ n ≡ p)
                    → (ma : ⟨ EffMonadTC m ⟩ α)
                    → (f : α → ⟨ EffMonadTC n ⟩ β)
                    → subst (λ X → ⟨ EffMonadTC X ⟩ β) assoc (ma >>= f) 
                    ≡ subst (λ X → ⟨ EffMonadTC X ⟩ β) outer ((subst (λ X → ⟨ EffMonadTC X ⟩ α) inner ma) >>= f)
    assocSubstShift refl refl refl ma f = refl

    lawAssoc : ∀ {α β γ : Type} 
             → (M N P S T : TyCons)
             → (b₁ : Binds M N P α γ) → (b₂ : Binds S T N β γ)
             → (b₃ : Binds N T P β γ) → (b₄ : Binds M S N α β)
             → (m : ⟨ M ⟩ α) → (f : α → ⟨ S ⟩ β) → (g : β → ⟨ T ⟩ γ)
             → bind b₁ m (λ x → bind b₂ (f x) g) ≡ bind b₃ (bind b₄ m f) g
    lawAssoc {β = β} {γ = γ} (EffMonadTC m) (EffMonadTC .(s ∙ t)) (EffMonadTC .(m ∙ (s ∙ t))) (EffMonadTC s) (EffMonadTC t) refl refl b₃ b₄ ma f g = begin 
      ma >>= (λ x → f x >>= g)
        ≡⟨ EffectMonad.lawAssoc monad ma f g ⟩
      subst₂ M (Monoid.lawAssoc monoid m s t) refl ((ma >>= f) >>= g)
        ≡⟨ subst₂ToSubst (Monoid.lawAssoc monoid m s t) ((ma >>= f) >>= g) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ γ) (Monoid.lawAssoc monoid m s t) ((ma >>= f) >>= g)
        ≡⟨ assocSubstShift (Monoid.lawAssoc monoid m s t) (sym b₄) (sym b₃) (ma >>= f) g ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym b₃) ((subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b₄) (ma >>= f)) >>= g)
        ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym b₃) (X >>= g)) (sym (bindSubstShift b₄ ma f)) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym b₃) ((subst (λ X → [ ⟨ EffMonadTC m ⟩ , ⟨ EffMonadTC s ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b₄) (_>>=_) ma f) >>= g)
        ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym b₃) ((X ma f) >>= g)) (sym (bindEq b₄)) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym b₃) ((bind b₄ ma f) >>= g)
        ≡⟨ sym (bindSubstShift b₃ (bind b₄ ma f) g) ⟩
      subst (λ X → [ ⟨ EffMonadTC (s ∙ t) ⟩ , ⟨ EffMonadTC t ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b₃) (_>>=_) (bind b₄ ma f) g
        ≡⟨ cong (λ X → X (bind b₄ ma f) g) (sym (bindEq b₃)) ⟩
      bind b₃ (bind b₄ ma f) g ∎
    
    functor : (M : TyCons) → Functor ⟨ M ⟩
    functor (EffMonadTC m) = record 
      { fmap = fmap
      ; lawId = lawId
      ; lawDist = lawDist
      } where
        lawId : ∀ {α : Type} → fmap {α = α} identity ≡ identity
        lawId {α = α} = funExt (λ ma → begin
          fmap identity ma 
            ≡⟨ refl ⟩
          subst₂ M (Monoid.lawIdR monoid m) refl (ma >>= (return' ∘ identity))
            ≡⟨ cong (λ X → subst₂ M (Monoid.lawIdR monoid m) refl X) (EffectMonad.lawIdR monad ma) ⟩
          subst₂ M (Monoid.lawIdR monoid m) refl (subst₂ M (sym (Monoid.lawIdR monoid m)) refl ma)
            ≡⟨ subst₂²≡id1 (Monoid.lawIdR monoid m) refl M ma ⟩
          identity ma ∎)
        
        bindFunSubstShift : {α β : Type} {m n p : Effect}
                          → (eq : n ≡ p)
                          → (ma : M m α)
                          → (f : α → M n β)
                          → subst (λ X → M X β) (cong (λ X → m ∙ X) eq) (ma >>= f)
                          ≡ ma >>= (λ a → subst (λ X → M X β) eq (f a))
        bindFunSubstShift refl ma f = refl
        
        lawDist : ∀ {α β γ : Type} 
                → (f : β → γ) → (g : α → β) 
                → fmap (f ∘ g) ≡ fmap f ∘ fmap g
        lawDist {β = β} {γ = γ} f g = funExt (λ ma → begin
          fmap (f ∘ g) ma 
            ≡⟨ refl ⟩
          subst₂ M (Monoid.lawIdR monoid m) refl (ma >>= (return' ∘ (f ∘ g)))
            ≡⟨ subst₂ToSubst (Monoid.lawIdR monoid m) (ma >>= (return' ∘ (f ∘ g))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (Monoid.lawIdR monoid m) (ma >>= (return' ∘ (f ∘ g)))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) X (ma >>= (return' ∘ (f ∘ g)))) 
                    (proof-irrelevance (Monoid.lawIdR monoid m) 
                                       (trans (cong (λ X → m ∙ X) (sym (Monoid.lawIdL monoid ε))) 
                                              (trans (sym (Monoid.lawAssoc monoid m ε ε)) 
                                                     (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m))))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → m ∙ X) (sym (Monoid.lawIdL monoid ε))) 
                                                  (trans (sym (Monoid.lawAssoc monoid m ε ε)) 
                                                         (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m))))
                (ma >>= (return' ∘ (f ∘ g)))
            ≡⟨ sym (substTrans (cong (λ X → m ∙ X) (sym (Monoid.lawIdL monoid ε))) 
                               (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m))) 
                               (λ X → ⟨ EffMonadTC X ⟩ γ) (ma >>= (return' ∘ (f ∘ g)))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)))
                (subst (λ X → ⟨ EffMonadTC X ⟩ γ) (cong (λ X → m ∙ X) (sym (Monoid.lawIdL monoid ε))) (ma >>= (return' ∘ (f ∘ g))))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m))) X) 
                    (bindFunSubstShift (sym (Monoid.lawIdL monoid ε)) ma (return' ∘ (f ∘ g))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)))
                (ma >>= (λ a → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym (Monoid.lawIdL monoid ε)) (return' (f (g a)))))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m))) (ma >>= X))
                    (funExt (λ a → sym (subst₂ToSubst (sym (Monoid.lawIdL monoid ε)) (return' (f (g a)))))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)))
                (ma >>= (λ a → subst₂ M (sym (Monoid.lawIdL monoid ε)) refl (return' (f (g a)))))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)))
                (ma >>= X)) (funExt (λ a → sym (EffectMonad.lawIdL monad (g a) (return' ∘ f)))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)))
                (ma >>= (λ a → return' (g a) >>= (return' ∘ f)))
            ≡⟨ sym (substTrans (sym (Monoid.lawAssoc monoid m ε ε)) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) 
                               (λ X → ⟨ EffMonadTC X ⟩ γ) 
                               (ma >>= (λ a → return' (g a) >>= (return' ∘ f)))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) 
                (subst (λ X → ⟨ EffMonadTC X ⟩ γ) (sym (Monoid.lawAssoc monoid m ε ε)) (ma >>= (λ a → return' (g a) >>= (return' ∘ f))))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) X) 
                    (sym (subst₂ToSubst (sym (Monoid.lawAssoc monoid m ε ε)) (ma >>= (λ a → return' (g a) >>= (return' ∘ f))))) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) 
                (subst₂ M (sym (Monoid.lawAssoc monoid m ε ε)) refl (ma >>= (λ a → return' (g a) >>= (return' ∘ f))))
            ≡⟨ cong (λ X → subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) X) 
                    (EffectMonad.symLawAssoc monad ma (return' ∘ g) (return' ∘ f)) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) 
                ((ma >>= (return' ∘ g)) >>= (return' ∘ f))
            ≡⟨ assocSubstShift (trans (cong (λ X → X ∙ ε) (Monoid.lawIdR monoid m)) (Monoid.lawIdR monoid m)) 
                               (Monoid.lawIdR monoid m) (Monoid.lawIdR monoid m) (ma >>= (return' ∘ g)) (return' ∘ f) ⟩
          subst (λ X → ⟨ EffMonadTC X ⟩ γ) (Monoid.lawIdR monoid m) ((subst (λ X → ⟨ EffMonadTC X ⟩ β) (Monoid.lawIdR monoid m) (ma >>= (return' ∘ g))) >>= (return' ∘ f))
            ≡⟨ sym (subst₂ToSubst (Monoid.lawIdR monoid m) ((subst (λ X → ⟨ EffMonadTC X ⟩ β) (Monoid.lawIdR monoid m) (ma >>= (return' ∘ g))) >>= (return' ∘ f))) ⟩
          subst₂ M (Monoid.lawIdR monoid m) refl ((subst (λ X → ⟨ EffMonadTC X ⟩ β) (Monoid.lawIdR monoid m) (ma >>= (return' ∘ g))) >>= (return' ∘ f))
            ≡⟨ cong (λ Y → subst₂ M (Monoid.lawIdR monoid m) refl (Y >>= (return' ∘ f))) (sym (subst₂ToSubst (Monoid.lawIdR monoid m) (ma >>= (return' ∘ g)))) ⟩
          subst₂ M (Monoid.lawIdR monoid m) refl ((subst₂ M (Monoid.lawIdR monoid m) refl (ma >>= (return' ∘ g))) >>= (return' ∘ f))
            ≡⟨ refl ⟩
          (fmap f ∘ fmap g) ma ∎)
    
    lawMonadFmap : ∀ {α β : Type}
                 → (M N : TyCons)
                 → (b : Binds M N M α β) → (r : Returns N β)
                 → (f : α → β) → (m : ⟨ M ⟩ α)
                 → bind b m (return r ∘ f) ≡ Functor.fmap (functor M) f m
    lawMonadFmap {β = β} (EffMonadTC x) (EffMonadTC .ε) b refl f ma = begin
      bind b ma (return' ∘ f) 
        ≡⟨ cong (λ X → X ma (return' ∘ f)) (bindEq b) ⟩
      subst (λ X → [ ⟨ EffMonadTC x ⟩ , ⟨ EffMonadTC ε ⟩ ]▷ ⟨ EffMonadTC X ⟩ ) (sym b) (_>>=_) ma (return' ∘ f)
        ≡⟨ bindSubstShift b ma (return' ∘ f) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (sym b) (ma >>= (return' ∘ f))
        ≡⟨ cong (λ Y → subst (λ X → ⟨ EffMonadTC X ⟩ β) Y (ma >>= (return' ∘ f))) (proof-irrelevance (sym b) (Monoid.lawIdR monoid x)) ⟩
      subst (λ X → ⟨ EffMonadTC X ⟩ β) (Monoid.lawIdR monoid x) (ma >>= (return' ∘ f))
        ≡⟨ sym (subst₂ToSubst (Monoid.lawIdR monoid x) (ma >>= (return' ∘ f))) ⟩
      subst₂ M (Monoid.lawIdR monoid x) refl (ma >>= (return' ∘ f))
        ≡⟨ refl ⟩
      fmap f ma ∎
{-
EffectMonad→HaskSuperMonad : ∀ {n}
                     → (Effect : Set n)
                     → (EffectMonoid : Monoid Effect)
                     → (M : Effect → TyCon)
                     → EffectMonad Effect {{EffectMonoid}} M → HaskSuperMonad (EffMonadTyCons Effect)
EffectMonad→HaskSuperMonad Effect monoid M monad = record
  { supermonad = supermonad
  ; lawUniqueBind = lawUniqueBind
  ; lawCommuteFmapBind = lawCommuteFmapBind
  ; lawDecomposeFmapIntro = lawDecomposeFmapIntro
  } where
    supermonad : SuperMonad (EffMonadTyCons Effect)
    supermonad = EffectMonad→SuperMonad Effect monoid M monad
    
    TyCons = EffMonadTyCons Effect
    Binds = SuperMonad.Binds supermonad
    ⟨_⟩ = SuperMonad.⟨_⟩ supermonad
    bind = SuperMonad.bind supermonad
    functor = SuperMonad.functor supermonad
    _◆_ = SuperMonad._◆_ supermonad
    
    _>>=_ = EffectMonad._>>=_ monad
    return = EffectMonad.return monad
    
    _∙_ = Monoid._∙_ monoid
    ε = Monoid.ε monoid
    
    open Functor.Functor
    
    lawUniqueBind : {α β : Type}
                  → (M N : TyCons)
                  → (b₁ b₂ : Binds M N)
                  → (m : ⟨ M ⟩ α) → (f : α → ⟨ N ⟩ β)
                  → bind b₁ m f ≡ bind b₂ m f
    lawUniqueBind (EffMonadTC x) (EffMonadTC y) (lift tt) (lift tt) m f = refl
    
    
    shiftSubstHelp1 : ∀ {α β : Type} {e e₁ e₂ m : Monoid.carrier monoid}
                    → (eqInner : e₁ ∙ e₂ ≡ m)
                    → (eqOuter : e ∙ (e₁ ∙ e₂) ≡ e ∙ m)
                    → (ma : ⟨ EffMonadTC e ⟩ α) → (f : α → ⟨ EffMonadTC (e₁ ∙ e₂) ⟩ β)
                    → subst₂ M eqOuter refl (ma >>= f) ≡ ma >>= (λ x → (subst₂ M eqInner refl (f x)))
    shiftSubstHelp1 refl refl ma f = refl
    
    shiftSubstHelp2 : ∀ {α β : Type} {e e₁ e₂ m : Monoid.carrier monoid}
                    → (eqInner : e₁ ∙ e₂ ≡ m)
                    → (eqOuter : (e₁ ∙ e₂) ∙ e ≡ m ∙ e)
                    → (ma : ⟨ EffMonadTC (e₁ ∙ e₂) ⟩ α) → (f : α → ⟨ EffMonadTC e ⟩ β)
                    → subst₂ M eqOuter refl (ma >>= f) ≡ (subst₂ M eqInner refl ma) >>= f
    shiftSubstHelp2 refl refl ma f = refl
    
    liftMonLaw : {e₁ e₂ : Monoid.carrier monoid} → (e₁ ≡ e₂) → EffMonadTC e₁ ≡ EffMonadTC e₂
    liftMonLaw refl = refl
    
    helpSubst1 : ∀ {β : Type}
               → {x y : Monoid.carrier monoid}
               → (monEq : x ≡ y)
               → (m : ⟨ EffMonadTC x ⟩ β) 
               → subst (λ X → ⟨ X ⟩ β) (liftMonLaw monEq) m
                 ≡ subst₂ M monEq refl m
    helpSubst1 refl m = refl
    
    helpSubstTrans : ∀ {β : Type}
                   → {x y z : Monoid.carrier monoid}
                   → (eq₁ : y ≡ z)
                   → (eq₂ : x ≡ y)
                   → (m : ⟨ EffMonadTC x ⟩ β) 
                   → subst₂ M eq₁ refl (subst₂ M eq₂ refl m)
                     ≡ subst₂ M (trans eq₂ eq₁) refl m
    helpSubstTrans refl refl m = refl
    
    lawCommuteFmapBind : {α β γ : Type} 
                       → (M N : TyCons)
                       → (b : Binds M N)
                       → (m : ⟨ M ⟩ α) → (f : α → ⟨ N ⟩ β) → (g : β → γ)
                       → fmap (functor (M ◆ N)) g (bind b m f) ≡ bind b m (λ x → fmap (functor N) g (f x))
    lawCommuteFmapBind {γ = γ} (EffMonadTC x) (EffMonadTC y) (lift tt) m f g = begin
      subst₂ M (Monoid.lawIdR monoid (x ∙ y)) refl ((m >>= f) >>= (return ∘ g))
        ≡⟨ cong (λ X → subst₂ M (Monoid.lawIdR monoid (x ∙ y)) refl X) 
                (sym (SuperMonad.lawAssoc supermonad (EffMonadTC x) (EffMonadTC y) (EffMonadTC ε) (liftMonLaw (sym (Monoid.lawAssoc monoid x y ε))) 
                                          (lift tt) (lift tt) (lift tt) (lift tt) m f (return ∘ g))) ⟩
      subst₂ M (Monoid.lawIdR monoid (x ∙ y)) refl (subst (λ X → ⟨ X ⟩ γ) (liftMonLaw (sym (Monoid.lawAssoc monoid x y ε))) (m >>= (λ x → f x >>= (return ∘ g))))
        ≡⟨ cong (λ X → subst₂ M (Monoid.lawIdR monoid (x ∙ y)) refl X) (helpSubst1 (sym (Monoid.lawAssoc monoid x y ε)) (m >>= (λ x → f x >>= (return ∘ g)))) ⟩
      subst₂ M (Monoid.lawIdR monoid (x ∙ y)) refl (subst₂ M (sym (Monoid.lawAssoc monoid x y ε)) refl (m >>= (λ x → f x >>= (return ∘ g))))
        ≡⟨ helpSubstTrans (Monoid.lawIdR monoid (x ∙ y)) (sym (Monoid.lawAssoc monoid x y ε)) (m >>= (λ x → f x >>= (return ∘ g))) ⟩
      subst₂ M (trans (sym (Monoid.lawAssoc monoid x y ε)) (Monoid.lawIdR monoid (x ∙ y))) refl (m >>= (λ x → f x >>= (return ∘ g)))
        ≡⟨ shiftSubstHelp1 (Monoid.lawIdR monoid y) (trans (sym (Monoid.lawAssoc monoid x y ε)) (Monoid.lawIdR monoid (x ∙ y))) m (λ x → f x >>= (return ∘ g)) ⟩
      m >>= (λ x → subst₂ M (Monoid.lawIdR monoid y) refl (f x >>= (return ∘ g))) ∎
    
    
    [xε]y≡xy : {x y : Monoid.carrier monoid} → (x ∙ ε) ∙ y ≡ x ∙ y
    [xε]y≡xy {x = x} {y = y} = cong (λ X → X ∙ y) (Monoid.lawIdR monoid x)
    
    [xε]y≡x[εy] : {x y : Monoid.carrier monoid} → (x ∙ ε) ∙ y ≡ x ∙ (ε ∙ y)
    [xε]y≡x[εy] {x = x} {y = y} = Monoid.lawAssoc monoid x ε y
    
    εx≡x : {x : Monoid.carrier monoid} → ε ∙ x ≡ x
    εx≡x {x = x} = Monoid.lawIdL monoid x
    
    shiftSubstHelp3 : ∀ {α β : Type} {e e₁ e₂ m : Monoid.carrier monoid}
                    → (eqInner : e₁ ∙ e₂ ≡ m)
                    → (eqOuter : e ∙ (e₁ ∙ e₂) ≡ e ∙ m)
                    → (ma : ⟨ EffMonadTC e ⟩ α) → (f : α → ⟨ EffMonadTC m ⟩ β)
                    → subst₂ M (sym eqOuter) refl (ma >>= f) ≡ ma >>= (λ x → (subst₂ M (sym eqInner) refl (f x)))
    shiftSubstHelp3 refl refl ma f = refl

    lawDecomposeFmapIntro : {α β γ : Type} 
                          → (M N : TyCons)
                          → (b : Binds M N)
                          → (m : ⟨ M ⟩ α) → (f : α → β) → (g : β → ⟨ N ⟩ γ)
                          → bind b m (g ∘ f) ≡ bind b (fmap (functor M) f m) g
    lawDecomposeFmapIntro {γ = γ} (EffMonadTC x) (EffMonadTC y) (lift tt) m f g = begin 
      m >>= (g ∘ f) 
        ≡⟨ sym (subst₂²≡id1 (trans (sym [xε]y≡x[εy]) [xε]y≡xy) refl M (m >>= (g ∘ f))) ⟩
      subst₂ M (trans (sym [xε]y≡x[εy]) [xε]y≡xy) refl (subst₂ M (sym (trans (sym [xε]y≡x[εy]) [xε]y≡xy)) refl (m >>= (g ∘ f)))
        ≡⟨ sym (helpSubstTrans [xε]y≡xy (sym [xε]y≡x[εy]) (subst₂ M (sym (trans (sym [xε]y≡x[εy]) [xε]y≡xy)) refl (m >>= (g ∘ f)))) ⟩
      subst₂ M [xε]y≡xy refl 
             (subst₂ M (sym [xε]y≡x[εy]) refl 
                     (subst₂ M (sym (trans (sym [xε]y≡x[εy]) [xε]y≡xy)) refl (m >>= (g ∘ f))))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl X)) (shiftSubstHelp3 εx≡x (trans (sym [xε]y≡x[εy]) [xε]y≡xy) m (g ∘ f)) ⟩
      subst₂ M [xε]y≡xy refl 
             (subst₂ M (sym [xε]y≡x[εy]) refl 
                     (m >>= (λ x → subst₂ M (sym εx≡x) refl (g (f x)))))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl (m >>= X))) (funExt (λ x → sym (helpSubst1 (sym εx≡x) (g (f x))))) ⟩
      subst₂ M [xε]y≡xy refl 
             (subst₂ M (sym [xε]y≡x[εy]) refl 
                     (m >>= (λ x → subst (λ X → ⟨ X ⟩ γ) (liftMonLaw (sym εx≡x)) (g (f x)))))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl (m >>= X))) 
                (funExt (λ x → cong (λ X → subst (λ X → ⟨ X ⟩ γ) X (g (f x))) (proof-irrelevance (liftMonLaw (sym εx≡x)) (sym (liftMonLaw εx≡x))))) ⟩
      subst₂ M [xε]y≡xy refl 
             (subst₂ M (sym [xε]y≡x[εy]) refl 
                     (m >>= (λ x → subst (λ X → ⟨ X ⟩ γ) (sym (liftMonLaw εx≡x)) (g (f x)))))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl (m >>= X))) 
                (funExt (λ x → cong (λ X → subst (λ X → ⟨ X ⟩ γ) (sym (liftMonLaw εx≡x)) X) 
                                    (sym (SuperMonad.lawIdR supermonad (EffMonadTC y) (EffMonadTC ε) (liftMonLaw εx≡x) (lift tt) refl (f x) g)))) ⟩
      subst₂ M [xε]y≡xy refl 
             (subst₂ M (sym [xε]y≡x[εy]) refl 
                     (m >>= (λ x → subst (λ X → ⟨ X ⟩ γ) (sym (liftMonLaw εx≡x)) (subst (λ X → ⟨ X ⟩ γ) (liftMonLaw εx≡x) (return (f x) >>= g)))))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl (m >>= X))) 
                (funExt (λ x → subst²≡id' (liftMonLaw εx≡x) (λ X → ⟨ X ⟩ γ) ((return (f x) >>= g)))) ⟩
      subst₂ M [xε]y≡xy refl (subst₂ M (sym [xε]y≡x[εy]) refl (m >>= (λ x → return (f x) >>= g)))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl X) (sym (helpSubst1 (sym (Monoid.lawAssoc monoid x ε y)) (m >>= (λ x → return (f x) >>= g)))) ⟩
      subst₂ M [xε]y≡xy refl (subst (λ X → ⟨ X ⟩ γ) (liftMonLaw (sym (Monoid.lawAssoc monoid x ε y))) (m >>= (λ x → return (f x) >>= g)))
        ≡⟨ cong (λ X → subst₂ M [xε]y≡xy refl X) 
                (SuperMonad.lawAssoc supermonad (EffMonadTC x) (EffMonadTC ε) (EffMonadTC y) 
                                     (liftMonLaw (sym [xε]y≡x[εy])) 
                                     (lift tt) (lift tt) (lift tt) (lift tt) 
                                     m (return ∘ f) g) ⟩
      subst₂ M [xε]y≡xy refl ((m >>= (return ∘ f)) >>= g)
        ≡⟨ shiftSubstHelp2 (Monoid.lawIdR monoid x) [xε]y≡xy ((m >>= (return ∘ f))) g ⟩
      (subst₂ M (Monoid.lawIdR monoid x) refl (m >>= (return ∘ f))) >>= g ∎

-}
