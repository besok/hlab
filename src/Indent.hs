module Indent (formatFile) where

import qualified Data.Text as T
import System.Directory (removeFile)
import System.Environment

type Indent = Int

type Statement = (String, String)

data Formatter = Formatter Indent [Statement]

split :: String -> Statement
split txt = stripStatement $ splitBy' txt ("", "")
  where
    splitBy' [] line = line
    splitBy' (c : rest) (lhs, rhs) | c == '=' = splitBy' [] (lhs, rhs ++ rest)
    splitBy' (c : rest) (lhs, rhs) = splitBy' rest (lhs ++ [c], rhs)

emptyFormatter :: Formatter
emptyFormatter = Formatter 0 []

newIndent :: Int -> Statement -> Int
newIndent currIndent (lhs, _) = max (length lhs) currIndent

addSt :: Formatter -> String -> Formatter
addSt (Formatter indent sts) line = Formatter (newIndent indent toLine) (sts ++ [toLine])
  where
    toLine = split line

correctIndent :: Formatter -> Formatter
correctIndent (Formatter indent sts) = Formatter indent (map correctIndent' sts)
  where
    correctIndent' (lhs, rhs) = (lhs ++ replicate (indent - length lhs) ' ', rhs)

formatSts :: Formatter -> [String]
formatSts (Formatter _ sts) = map format' sts
  where
    format' (lhs, []) = lhs
    format' (lhs, rhs) = lhs ++ " = " ++ rhs

format :: [String] -> [String]
format = formatSts . correctIndent . createFormatter
  where
    createFormatter = foldl addSt emptyFormatter

strip :: String -> String
strip = T.unpack . T.strip . T.pack

stripStatement :: Statement -> Statement
stripStatement (lhs, rhs) = (strip lhs, strip rhs)

formatFile :: FilePath -> IO ()
formatFile path = do
  let tmpFile = path ++ ".f"
  contents <- readFromFile path
  writeToFile tmpFile $ format contents
  fContents <- readFromFile tmpFile
  writeToFile path fContents
  removeFile tmpFile

readFromFile :: FilePath -> IO [String]
readFromFile path = do
  contents <- readFile path
  return $ lines contents

writeToFile :: FilePath -> [String] -> IO ()
writeToFile path strs = writeFile path $ unlines strs