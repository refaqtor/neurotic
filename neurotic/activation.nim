import linalg
import ./core, ./util

type
  Activation64* = ref object of Layer64
    lastInput: DVector64
    lastInputs: DMatrix64
    f: proc(x: DVector64): DVector64
    fm: proc(x: DMatrix64): DMatrix64
    fPrime: proc(x: DVector64): DVector64
    fmPrime: proc(x: DMatrix64): DMatrix64

proc sigmoid*(z: float64): float64 = 1.0 / (exp(-z) + 1.0)

proc sigmoidPrime*(z: float64): float64 = sigmoid(z) * (1.0 - sigmoid(z))

proc relu*(z: float64): float64 = max(z, 0.0)

proc reluPrime*(z: float64): float64 =
  if z >= 0: 1.0 else: 0.0

makeUniversal(sigmoid)
makeUniversal(sigmoidPrime)
makeUniversal(relu)
makeUniversal(reluPrime)

method forward*(a: Activation64, x: DVector64): DVector64 =
  a.lastInput = x
  return a.f(x)

method forward*(a: Activation64, x: DMatrix64): DMatrix64 =
  a.lastInputs = x
  return a.fm(x)

method backward*(a: Activation64, v: DVector64, eta: float64): DVector64 =
  a.fPrime(a.lastInput) |*| v

method backward*(a: Activation64, v: DMatrix64, eta: float64): DMatrix64 =
  a.fmPrime(a.lastInputs) |*| v

proc sigmoidModule*(): Activation64 = Activation64(
  f: sigmoid,
  fm: sigmoid,
  fPrime: sigmoidPrime,
  fmPrime: sigmoidPrime
)

proc reluModule*(): Activation64 = Activation64(
  f: relu,
  fm: relu,
  fPrime: reluPrime,
  fmPrime: reluPrime
)