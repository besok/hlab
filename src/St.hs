module St () where

import Control.Monad (foldM, forM)
import Control.Monad.State

type LogRecord = String

data Steps a = Empty | Last a | Inter a (Steps a) deriving (Show)

add :: a -> Steps a -> Steps a
add x Empty = Last x
add x (Last y) = Inter y (Last x)
add x (Inter y steps) = Inter y (add x steps)

data LogSteps a = LogSteps (Steps a) LogRecord deriving (Show)

empty :: LogSteps a
empty = LogSteps Empty ""

getLog :: LogSteps a -> LogRecord
getLog (LogSteps _ log) = log

append :: (Show a) => a -> LogSteps a -> LogSteps a
append x (LogSteps steps log) = LogSteps (add x steps) $ log ++ show x

logStep :: (Show a) => a -> State (LogSteps a) ()
logStep x = modify $ append x

logSteps :: (Show a) => [a] -> State (LogSteps a) LogRecord
logSteps elems = forM elems logStep >> gets getLog