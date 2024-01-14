module Main (main) where
import System.Environment
import System.Directory (removeFile)
import Indent (formatFile)

main :: IO ()
main = do
  args <- getArgs
  case args of
        [path] -> formatFile path
        _ -> putStrLn "Please enter a correct path."

 