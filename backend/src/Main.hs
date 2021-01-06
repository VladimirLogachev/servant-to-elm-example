{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Data.Aeson
import qualified Data.Aeson as Aeson
import Data.Foldable
import qualified Data.HashMap.Lazy as HashMap
import Data.Proxy
import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Prettyprint.Doc (Doc)
import Data.Text.Prettyprint.Doc.Render.Text (hPutDoc)
import GHC.Generics
import qualified Generics.SOP as SOP
import Language.Elm.Name (Module)
import qualified Language.Elm.Pretty as Pretty
import qualified Language.Elm.Simplification as Simplification
import Language.Haskell.To.Elm
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Servant.API
import Servant.To.Elm
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)
import System.IO (IOMode (..), withFile)

data Book = Book
  { title :: Text,
    authorName :: Text
  }
  deriving (Eq, Show, Read, Generic, Aeson.ToJSON, Aeson.FromJSON, SOP.Generic, SOP.HasDatatypeInfo)

type BookAPI = "book" :> Get '[JSON] (Headers '[Header "Access-Control-Allow-Origin" String, Header "Access-Control-Allow-Headers" String] Book)

bookApi :: Proxy BookAPI
bookApi = Proxy

bookExample :: Book
bookExample = Book "Haskell in Depth" "Vitaly Bragilevsky"

server :: Server BookAPI
server = pure $ (addHeader "*" . addHeader "Content-Type") bookExample

app :: Application
app = serve bookApi server

main :: IO ()
main = run 8080 app

-- Code generation

-- Problems: Elm module path/name

instance HasElmType Book where
  elmDefinition =
    Just $ deriveElmTypeDefinition @Book Language.Haskell.To.Elm.defaultOptions "Api.Book.Book"

instance HasElmDecoder Aeson.Value Book where
  elmDecoderDefinition =
    Just $ deriveElmJSONDecoder @Book Language.Haskell.To.Elm.defaultOptions Aeson.defaultOptions "Api.Book.decoder"

instance HasElmEncoder Aeson.Value Book where
  elmEncoderDefinition =
    Just $ deriveElmJSONEncoder @Book Language.Haskell.To.Elm.defaultOptions Aeson.defaultOptions "Api.Book.encoder"

writeContentsToFile :: forall ann. Module -> Doc ann -> IO ()
writeContentsToFile _moduleName contents = do
  let path = T.unpack $ "../frontend/src/" <> T.intercalate "." _moduleName <> ".elm"
  createDirectoryIfMissing True $ takeDirectory path
  print $ "writing " <> path <> " ..."
  withFile path WriteMode (`hPutDoc` contents)

-- No instance for (HasElmDecoder
--                      Value
--                      (Headers
--                         '[Header "Access-Control-Allow-Origin" String,
--                           Header "Access-Control-Allow-Headers" String]
--                         Book))

-- generateElm :: IO ()
-- generateElm = do
--   let definitions =
--         map (elmEndpointDefinition "Config.urlBase" ["Api"]) (elmEndpoints @BookAPI)
--           <> jsonDefinitions @Book

--       modules =
--         Pretty.modules $
--           Simplification.simplifyDefinition <$> definitions

--   forM_ (HashMap.toList modules) $ uncurry writeContentsToFile
