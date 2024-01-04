module St () where

import Control.Monad.State
import Control.Monad (foldM)

data Steps a = Empty | Last a | Inter a (Steps a) deriving (Show)

add :: a -> Steps a -> Steps a
add step Empty = Last step
add step (Last a) = Inter a (Last step)
add step (Inter a b) = Inter a $ add step b

start :: State (Steps a) String
start = do
  put $ Empty
  return $ "|"

addWithLog :: (Show a) => a -> State (Steps a) String
addWithLog step = do
  modify $ add step
  return $ show step

process :: (Show a) => State (Steps a) String -> a -> State (Steps a) String
process state step  = do
  rhs <- addWithLog step
  lhs <- state
  return $ lhs ++ rhs

run :: (Show a) => [a] ->   String
run elems = evalState (foldl process start elems) Empty
