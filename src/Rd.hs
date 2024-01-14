module Rd () where

import Control.Monad.Reader

data Cfg = Cfg
  { prefix :: String,
    suffix :: String,
    len :: Maybe Int
  }

defaultCfg =
  Cfg
    { prefix = "",
      suffix = "",
      len = Nothing
    }
cfg =
  Cfg
    { prefix = ">|",
      suffix = "|<",
      len = Just 20
    }

lengthStrict :: String -> Maybe Int -> String
lengthStrict s (Just n ) = take n s ++ "..."
lengthStrict s Nothing = s

message :: String -> Reader Cfg String
message s = do
  Cfg { len = mbLen } <- ask
  return $ lengthStrict s mbLen

frameMessage ::  String -> Reader Cfg String
frameMessage m = do
  Cfg { prefix = p, suffix = s } <- ask
  return $ p ++ m ++ s

transformString :: String -> Cfg -> String
transformString m cfg = do runReader (message m >>= frameMessage) cfg