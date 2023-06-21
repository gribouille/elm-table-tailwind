module Users exposing (..)


type alias User =
    { id : Int
    , firstname : String
    , lastname : String
    , age : Int
    }


users : List User
users =
    [ User 1 "Bob" "Leponge" 22
    , User 2 "Ektor" "Plankton" 21
    , User 3 "Mr" "Krabs" 33
    , User 4 "Linus" "Torwald" 43
    , User 5 "Darlene" "Fleming" 26
    , User 6 "Rodney" "Black" 45
    , User 7 "Joy" "Bishop" 23
    , User 8 "Megan" "Bennett" 47
    , User 9 "Tara" "Williams" 52
    , User 10 "Andy" "King" 11
    , User 11 "Leroy" "Fox" 23
    , User 12 "Felicia" "Castillo" 47
    , User 13 "Tammy" "Carter" 10
    , User 14 "Derrick" "Johnston" 32
    , User 15 "Juan" "Little" 45
    ]
