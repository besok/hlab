module Fd () where

import Control.Exception (handle)
import Control.Monad (forM)
import System.Directory (doesDirectoryExist, listDirectory)

type FilterByName = String -> Bool

fd :: FilterByName -> FilePath -> IO [FilePath]
fd f p = do
  files <- listDirectory p
  elems <- forM files handleFile
  return $ concat elems
  where
    handleFile item = do
      isDir <- doesDirectoryExist item
      if isDir
        then fd f item
        else return [item | f item]


byName :: String -> FilterByName
byName name x = x == name

byExt :: String -> FilterByName
byExt ext x = ext == fileExt
    where
        fileExt = reverse $ take (length ext) $ reverse x