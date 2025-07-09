function RequiredAnswer(checkIsAnswer, doAnswerLogic, timeToDie, onDie)
    return{
        isAnswer = checkIsAnswer,
        timeToDie = timeToDie,
        doAnswerLogic = doAnswerLogic,
        onDie = onDie
    }
end