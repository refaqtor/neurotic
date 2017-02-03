import sequtils
import neurotic, linalg

proc adjustTest(x: tuple[a: DMatrix64, b: DVector64]): (DVector64, int) =
  let (m, v) = x
  let (i, _) = maxIndex(v)
  (m.asVector, i)

proc adjustTrain(x: tuple[a: DMatrix64, b: DVector64]): TrainingData64 =
  let (m, v) = x
  (input: m.asVector, output: v)


proc main() =
  let
    l1 = dense(784, 50)
    l2 = dense(50, 10)
    cost = QuadraticCost()
  var
    m1 = l1.withMemory
    # m2 = sigmoidModule()
    m2 = reluModule()
    m3 = l2.withMemory
    m4 = sequential(@[m1, m2, m3])

  let data = mnistTrainData().map(adjustTrain)
  for _ in 1 .. 10:
    # sgd(m4, cost, data)
    miniBatchSgd(m4, cost, data)

  let testData = mnistTestData().map(adjustTest)
  let rightAnswers = m4.evaluate(testData)
  let perc = rightAnswers.float * 100.0 / testData.len.float
  echo "Right answers: ", rightAnswers, " out of ", testData.len
  echo "Perc: ", perc, "%"

when isMainModule:
  main()