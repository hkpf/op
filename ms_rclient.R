##########################################################
#       Load Model & write prediction function       #
##########################################################

# If on R Server 9.0, load mrsdeploy package now
library(mrsdeploy)
library(randomForest)
# train models: done in other script already

## load models ####
model.large <- readRDS(file = "models/model_rf_60000.rds")
model.small <- readRDS(file = "models/model_rf_1000.rds")

## paste together prediction function with variables as input, not needed for our case ####

variablenames <- paste0(rep("V", 7), 1:7)
var.names.conc <- paste(variablenames, sep = ",")

# the way to go
as.name("V1, V2")
paste("V1", "V2", sep = ",")

test <- function(a,b){
    a+b
}
test(1,2)

# not working
# nm <- as.name("a, b")
# test2 <- function(nm){
#     a+b
# }

# following works
test3 <- function(){
    a+b
}
args <- alist(a=, b=)
formals(test3) <- args
test3(1,2)
# now use eval of parse() with text=<string> to change the string into an expression:
#     
#     > eval(parse(text="5+5"))
# [1] 10

# SOLUTION: ###
string <- "alist(a=, b=)"
args2 <- eval(parse(text=string))
test4 <- function(){
    a+b
}
formals(test4) <- args2
test4(1,2)
###
# now get it working for our problem:
var.nm <- paste0(rep("V", 7), 1:7)
var.nm.string <- paste0(var.nm, "= ,", collapse = "")
args <- eval(parse(text=var.nm.string))
test <- function(){
    a+b
}
formals(test) <- args


var.nm <- paste0(rep("V", 784), 1:784)
(var.nm.string <- paste0(var.nm, "=,", collapse = ""))
(var.nm.string2 <- paste0(var.nm, "=", var.nm, ", ", collapse = ""))
# remove last komma in string
(var.nm.string <- substr(var.nm.string, start = 1, stop = nchar(var.nm.string) - 1))
(var.nm.string2 <- substr(var.nm.string2, start = 1, stop = nchar(var.nm.string2) - 2))
alist.string <- paste0("alist(", var.nm.string, ")")
df.string <- paste0("data.frame(", var.nm.string2, ")")
alist.expr <- eval(parse(text=alist.string))
#df.expr <- eval(parse(text=df.string))

test <- function(){
    df <- data.frame(V1=V1, V2=V2)
}
formals(test) <- alist.expr


predict.large <- function(){   
    newdata.frame <- parse(text=df.string) # not yet working. new idea: newdata <- data.frame() # now add columns to data frame
    prediction <- predict(model.large, newdata = newdata.frame, type = "response")
    as.numeric(as.character(prediction))
}
formals(predict.large) <- alist.expr


debug(predict.large)
predict.large(as.numeric(d.test[1,-785]))



# want:
predict.large <- function(V1, V2, ..., V784){   
    newdata <- data.frame(V1 = V1, V2 = V2, ..., V784 = V784)
    prediction <- predict(model.large, newdata = data.frame, type = "response")
    as.numeric(as.character(prediction))
}



## prediction with vector as input ####

# not working: (return not working)
# predict.small <- function(num.vec){ 
#     prediction <- predict(model.small, newdata = num.vec, type = "response")
#     return(as.numeric(as.character(prediction)))
# }
# debug(predict.small)



# folgendes gibt als return NULL zurück
predictsmall <- function(num.vec){ ## use V1, V2, ...
    prediction <- predict(model.small, newdata = num.vec, type = "response")
    as.numeric(as.character(prediction))
}

predict.empty <- function(num.vec){
    0
}



## test function locally by printing results ####

d.test <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")
obs <- 8
predict.large(rep(0, 784))
predict.large(d.test[1,-785])

predict.small(rep(0, 784))
predict.small(as.numeric(d.test[1,-785]))

predict.empty(rep(0, 784))
predict.empty(d.test[1,-785])
##########################################################
#            Log into Server                 #
##########################################################

# Use `remoteLogin` to authenticate with Server using 
# the local admin account. Use session = false so no 
# remote R session started
remoteLogin("http://lin-op-vm.westeurope.cloudapp.azure.com:12800", 
                        session = FALSE)
# user: admin
# pw: ...OnBo.

##########################################################
#             Publish Model as a Service                 #
##########################################################

# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName.large <- paste0("predictlarge", 12345)
serviceName.small <- paste0("predictsmall", 12345)
serviceName.empty <- paste0("predictempty", 12345)

# List of variable names:
variablenames <- paste0(rep("V", 784), 1:784)
varnames.list <- list()
for(i in 1:784){
    varnames.list[[ variablenames[i] ]] <- "numeric"
}
head(varnames.list)
tail(varnames.list)


# Publish as service using publishService() function from 
# mrsdeploy package. Name service "predictlarge" and provide
# unique version number. Assign service to the variable `api`
api.large <- publishService(
    serviceName.large,
    code = predict.large,
    model = model.large,
    inputs = varnames.list,
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
# folgendes gibt als return NULL zurück
api.small<- publishService(
    serviceName.small,
    code = predictsmall,
    model = model.small,
    inputs = list(num.vec = "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
#deleteService(serviceName.small, "v1.0.0")

# test without model
api.empty<- publishService(
    serviceName.empty,
    code = predict.empty,
    # model = 
    inputs = list(num.vec = "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
#deleteService(serviceName.empty, "v1.0.0")

# test with only one numeric number as input (vector length 1)   -> works
test <- function(a){
    a
}
    
api.test <- publishService(
    "test123",
    code = test,
    # model = 
    inputs = list(a= "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)

# test with two numeric numbers as input (2 vectors length 1)   -> works
test3 <- function(a,b){
    a+b
}

api.test3 <- publishService(
    "test3123",
    code = test3,
    # model = 
    inputs = list(a= "numeric", b = "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
result <- api.test3$test3(1,2)
str(result)

# test with numeric vector of length 2 as input -> NOT working!!!
test2 <- function(a){
    a[1]+a[2]
}

api.test2 <- publishService(
    "test2123",
    code = test2,
    # model = 
    inputs = list(a= "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
#deleteService("test2123", "v1.0.0")

a <- 1:2
str(a)
result <- api.test2$test2(a) # not working



# model with 5 variables, and input = 5 numbers in tryout -> working
str(mtcars)
fit <- lm(mpg ~ cyl + disp + hp +  wt + qsec, data = mtcars)
pr <- function(cyl, disp, hp, wt, qsec){
    newdata <-  data.frame(cyl = cyl, disp = disp, hp = hp,  wt =  wt, qsec = qsec)
    predict(fit, newdata = newdata,  wt =  wt, qsec = qsec)
}
api.test4 <- publishService(
    "test4123",
    code = pr,
    model = fit,
    inputs = list(cyl = "numeric", disp = "numeric", hp = "numeric",  wt = "numeric", qsec = "numeric"),
    outputs = list(label= "numeric"),
    v = "v1.0.0"
)
#deleteService("test4123", "v1.0.0")
pr(cyl = 21, disp = 4, hp = 115,  wt =  3, qsec = 16 )
result <- api.test4$pr(cyl = 21, disp = 4, hp = 115,  wt =  3, qsec = 16 )
result <- api.test4$pr(21,  4, 115,  3, 16 ) #tryout
str(result)




# need Input transformation: c(3,4,4) -> "c(3,3,3)" -> "3,3,3" TO DO: continue here!!!


# model with 784 variables, hardcoded !!!! geht beim testen nicht weil input ein Vektor ist, muss den Vektor in 784 einzelne Zahlen umwandeln!!!!! ####
# Hardcoded version:
predict.small <- function(V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, 
                          V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, 
                          V25, V26, V27, V28, V29, V30, V31, V32, V33, V34, V35, V36, 
                          V37, V38, V39, V40, V41, V42, V43, V44, V45, V46, V47, V48, 
                          V49, V50, V51, V52, V53, V54, V55, V56, V57, V58, V59, V60, 
                          V61, V62, V63, V64, V65, V66, V67, V68, V69, V70, V71, V72, 
                          V73, V74, V75, V76, V77, V78, V79, V80, V81, V82, V83, V84, 
                          V85, V86, V87, V88, V89, V90, V91, V92, V93, V94, V95, V96, 
                          V97, V98, V99, V100, V101, V102, V103, V104, V105, V106, 
                          V107, V108, V109, V110, V111, V112, V113, V114, V115, V116, 
                          V117, V118, V119, V120, V121, V122, V123, V124, V125, V126, 
                          V127, V128, V129, V130, V131, V132, V133, V134, V135, V136, 
                          V137, V138, V139, V140, V141, V142, V143, V144, V145, V146, 
                          V147, V148, V149, V150, V151, V152, V153, V154, V155, V156, 
                          V157, V158, V159, V160, V161, V162, V163, V164, V165, V166, 
                          V167, V168, V169, V170, V171, V172, V173, V174, V175, V176, 
                          V177, V178, V179, V180, V181, V182, V183, V184, V185, V186, 
                          V187, V188, V189, V190, V191, V192, V193, V194, V195, V196, 
                          V197, V198, V199, V200, V201, V202, V203, V204, V205, V206, 
                          V207, V208, V209, V210, V211, V212, V213, V214, V215, V216, 
                          V217, V218, V219, V220, V221, V222, V223, V224, V225, V226, 
                          V227, V228, V229, V230, V231, V232, V233, V234, V235, V236, 
                          V237, V238, V239, V240, V241, V242, V243, V244, V245, V246, 
                          V247, V248, V249, V250, V251, V252, V253, V254, V255, V256, 
                          V257, V258, V259, V260, V261, V262, V263, V264, V265, V266, 
                          V267, V268, V269, V270, V271, V272, V273, V274, V275, V276, 
                          V277, V278, V279, V280, V281, V282, V283, V284, V285, V286, 
                          V287, V288, V289, V290, V291, V292, V293, V294, V295, V296, 
                          V297, V298, V299, V300, V301, V302, V303, V304, V305, V306, 
                          V307, V308, V309, V310, V311, V312, V313, V314, V315, V316, 
                          V317, V318, V319, V320, V321, V322, V323, V324, V325, V326, 
                          V327, V328, V329, V330, V331, V332, V333, V334, V335, V336, 
                          V337, V338, V339, V340, V341, V342, V343, V344, V345, V346, 
                          V347, V348, V349, V350, V351, V352, V353, V354, V355, V356, 
                          V357, V358, V359, V360, V361, V362, V363, V364, V365, V366, 
                          V367, V368, V369, V370, V371, V372, V373, V374, V375, V376, 
                          V377, V378, V379, V380, V381, V382, V383, V384, V385, V386, 
                          V387, V388, V389, V390, V391, V392, V393, V394, V395, V396, 
                          V397, V398, V399, V400, V401, V402, V403, V404, V405, V406, 
                          V407, V408, V409, V410, V411, V412, V413, V414, V415, V416, 
                          V417, V418, V419, V420, V421, V422, V423, V424, V425, V426, 
                          V427, V428, V429, V430, V431, V432, V433, V434, V435, V436, 
                          V437, V438, V439, V440, V441, V442, V443, V444, V445, V446, 
                          V447, V448, V449, V450, V451, V452, V453, V454, V455, V456, 
                          V457, V458, V459, V460, V461, V462, V463, V464, V465, V466, 
                          V467, V468, V469, V470, V471, V472, V473, V474, V475, V476, 
                          V477, V478, V479, V480, V481, V482, V483, V484, V485, V486, 
                          V487, V488, V489, V490, V491, V492, V493, V494, V495, V496, 
                          V497, V498, V499, V500, V501, V502, V503, V504, V505, V506, 
                          V507, V508, V509, V510, V511, V512, V513, V514, V515, V516, 
                          V517, V518, V519, V520, V521, V522, V523, V524, V525, V526, 
                          V527, V528, V529, V530, V531, V532, V533, V534, V535, V536, 
                          V537, V538, V539, V540, V541, V542, V543, V544, V545, V546, 
                          V547, V548, V549, V550, V551, V552, V553, V554, V555, V556, 
                          V557, V558, V559, V560, V561, V562, V563, V564, V565, V566, 
                          V567, V568, V569, V570, V571, V572, V573, V574, V575, V576, 
                          V577, V578, V579, V580, V581, V582, V583, V584, V585, V586, 
                          V587, V588, V589, V590, V591, V592, V593, V594, V595, V596, 
                          V597, V598, V599, V600, V601, V602, V603, V604, V605, V606, 
                          V607, V608, V609, V610, V611, V612, V613, V614, V615, V616, 
                          V617, V618, V619, V620, V621, V622, V623, V624, V625, V626, 
                          V627, V628, V629, V630, V631, V632, V633, V634, V635, V636, 
                          V637, V638, V639, V640, V641, V642, V643, V644, V645, V646, 
                          V647, V648, V649, V650, V651, V652, V653, V654, V655, V656, 
                          V657, V658, V659, V660, V661, V662, V663, V664, V665, V666, 
                          V667, V668, V669, V670, V671, V672, V673, V674, V675, V676, 
                          V677, V678, V679, V680, V681, V682, V683, V684, V685, V686, 
                          V687, V688, V689, V690, V691, V692, V693, V694, V695, V696, 
                          V697, V698, V699, V700, V701, V702, V703, V704, V705, V706, 
                          V707, V708, V709, V710, V711, V712, V713, V714, V715, V716, 
                          V717, V718, V719, V720, V721, V722, V723, V724, V725, V726, 
                          V727, V728, V729, V730, V731, V732, V733, V734, V735, V736, 
                          V737, V738, V739, V740, V741, V742, V743, V744, V745, V746, 
                          V747, V748, V749, V750, V751, V752, V753, V754, V755, V756, 
                          V757, V758, V759, V760, V761, V762, V763, V764, V765, V766, 
                          V767, V768, V769, V770, V771, V772, V773, V774, V775, V776, 
                          V777, V778, V779, V780, V781, V782, V783, V784){ 
    newdata.frame <- data.frame(V1=V1,V2=V2,V3=V3,V4=V4,V5=V5,V6=V6,V7=V7,V8=V8,V9=V9,V10=V10,V11=V11,V12=V12,V13=V13,V14=V14,V15=V15,V16=V16,
                                V17=V17,V18=V18,V19=V19,V20=V20,V21=V21,V22=V22,V23=V23,V24=V24,V25=V25,V26=V26,V27=V27,V28=V28,V29=V29,V30=V30,
                                V31=V31,V32=V32,V33=V33,V34=V34,V35=V35,V36=V36,V37=V37,V38=V38,V39=V39,V40=V40,V41=V41,V42=V42,V43=V43,V44=V44,
                                V45=V45,V46=V46,V47=V47,V48=V48,V49=V49,V50=V50,V51=V51,V52=V52,V53=V53,V54=V54,V55=V55,V56=V56,V57=V57,V58=V58,
                                V59=V59,V60=V60,V61=V61,V62=V62,V63=V63,V64=V64,V65=V65,V66=V66,V67=V67,V68=V68,V69=V69,V70=V70,V71=V71,V72=V72,
                                V73=V73,V74=V74,V75=V75,V76=V76,V77=V77,V78=V78,V79=V79,V80=V80,V81=V81,V82=V82,V83=V83,V84=V84,V85=V85,V86=V86,
                                V87=V87,V88=V88,V89=V89,V90=V90,V91=V91,V92=V92,V93=V93,V94=V94,V95=V95,V96=V96,V97=V97,V98=V98,V99=V99,
                                V100=V100,V101=V101,V102=V102,V103=V103,V104=V104,V105=V105,V106=V106,V107=V107,V108=V108,V109=V109,V110=V110,
                                V111=V111,V112=V112,V113=V113,V114=V114,V115=V115,V116=V116,V117=V117,V118=V118,V119=V119,V120=V120,V121=V121,
                                V122=V122,V123=V123,V124=V124,V125=V125,V126=V126,V127=V127,V128=V128,V129=V129,V130=V130,V131=V131,V132=V132,
                                V133=V133,V134=V134,V135=V135,V136=V136,V137=V137,V138=V138,V139=V139,V140=V140,V141=V141,V142=V142,V143=V143,
                                V144=V144,V145=V145,V146=V146,V147=V147,V148=V148,V149=V149,V150=V150,V151=V151,V152=V152,V153=V153,V154=V154,
                                V155=V155,V156=V156,V157=V157,V158=V158,V159=V159,V160=V160,V161=V161,V162=V162,V163=V163,V164=V164,V165=V165,
                                V166=V166,V167=V167,V168=V168,V169=V169,V170=V170,V171=V171,V172=V172,V173=V173,V174=V174,V175=V175,V176=V176,
                                V177=V177,V178=V178,V179=V179,V180=V180,V181=V181,V182=V182,V183=V183,V184=V184,V185=V185,V186=V186,V187=V187,
                                V188=V188,V189=V189,V190=V190,V191=V191,V192=V192,V193=V193,V194=V194,V195=V195,V196=V196,V197=V197,V198=V198,
                                V199=V199,V200=V200,V201=V201,V202=V202,V203=V203,V204=V204,V205=V205,V206=V206,V207=V207,V208=V208,V209=V209,
                                V210=V210,V211=V211,V212=V212,V213=V213,V214=V214,V215=V215,V216=V216,V217=V217,V218=V218,V219=V219,V220=V220,
                                V221=V221,V222=V222,V223=V223,V224=V224,V225=V225,V226=V226,V227=V227,V228=V228,V229=V229,V230=V230,V231=V231,
                                V232=V232,V233=V233,V234=V234,V235=V235,V236=V236,V237=V237,V238=V238,V239=V239,V240=V240,V241=V241,V242=V242,
                                V243=V243,V244=V244,V245=V245,V246=V246,V247=V247,V248=V248,V249=V249,V250=V250,V251=V251,V252=V252,V253=V253,
                                V254=V254,V255=V255,V256=V256,V257=V257,V258=V258,V259=V259,V260=V260,V261=V261,V262=V262,V263=V263,V264=V264,
                                V265=V265,V266=V266,V267=V267,V268=V268,V269=V269,V270=V270,V271=V271,V272=V272,V273=V273,V274=V274,V275=V275,
                                V276=V276,V277=V277,V278=V278,V279=V279,V280=V280,V281=V281,V282=V282,V283=V283,V284=V284,V285=V285,V286=V286,
                                V287=V287,V288=V288,V289=V289,V290=V290,V291=V291,V292=V292,V293=V293,V294=V294,V295=V295,V296=V296,V297=V297,
                                V298=V298,V299=V299,V300=V300,V301=V301,V302=V302,V303=V303,V304=V304,V305=V305,V306=V306,V307=V307,V308=V308,
                                V309=V309,V310=V310,V311=V311,V312=V312,V313=V313,V314=V314,V315=V315,V316=V316,V317=V317,V318=V318,V319=V319,
                                V320=V320,V321=V321,V322=V322,V323=V323,V324=V324,V325=V325,V326=V326,V327=V327,V328=V328,V329=V329,V330=V330,
                                V331=V331,V332=V332,V333=V333,V334=V334,V335=V335,V336=V336,V337=V337,V338=V338,V339=V339,V340=V340,V341=V341,
                                V342=V342,V343=V343,V344=V344,V345=V345,V346=V346,V347=V347,V348=V348,V349=V349,V350=V350,V351=V351,V352=V352,
                                V353=V353,V354=V354,V355=V355,V356=V356,V357=V357,V358=V358,V359=V359,V360=V360,V361=V361,V362=V362,V363=V363,
                                V364=V364,V365=V365,V366=V366,V367=V367,V368=V368,V369=V369,V370=V370,V371=V371,V372=V372,V373=V373,V374=V374,
                                V375=V375,V376=V376,V377=V377,V378=V378,V379=V379,V380=V380,V381=V381,V382=V382,V383=V383,V384=V384,V385=V385,
                                V386=V386,V387=V387,V388=V388,V389=V389,V390=V390,V391=V391,V392=V392,V393=V393,V394=V394,V395=V395,V396=V396,
                                V397=V397,V398=V398,V399=V399,V400=V400,V401=V401,V402=V402,V403=V403,V404=V404,V405=V405,V406=V406,V407=V407,
                                V408=V408,V409=V409,V410=V410,V411=V411,V412=V412,V413=V413,V414=V414,V415=V415,V416=V416,V417=V417,V418=V418,
                                V419=V419,V420=V420,V421=V421,V422=V422,V423=V423,V424=V424,V425=V425,V426=V426,V427=V427,V428=V428,V429=V429,
                                V430=V430,V431=V431,V432=V432,V433=V433,V434=V434,V435=V435,V436=V436,V437=V437,V438=V438,V439=V439,V440=V440,
                                V441=V441,V442=V442,V443=V443,V444=V444,V445=V445,V446=V446,V447=V447,V448=V448,V449=V449,V450=V450,V451=V451,
                                V452=V452,V453=V453,V454=V454,V455=V455,V456=V456,V457=V457,V458=V458,V459=V459,V460=V460,V461=V461,V462=V462,
                                V463=V463,V464=V464,V465=V465,V466=V466,V467=V467,V468=V468,V469=V469,V470=V470,V471=V471,V472=V472,V473=V473,
                                V474=V474,V475=V475,V476=V476,V477=V477,V478=V478,V479=V479,V480=V480,V481=V481,V482=V482,V483=V483,V484=V484,
                                V485=V485,V486=V486,V487=V487,V488=V488,V489=V489,V490=V490,V491=V491,V492=V492,V493=V493,V494=V494,V495=V495,
                                V496=V496,V497=V497,V498=V498,V499=V499,V500=V500,V501=V501,V502=V502,V503=V503,V504=V504,V505=V505,V506=V506,
                                V507=V507,V508=V508,V509=V509,V510=V510,V511=V511,V512=V512,V513=V513,V514=V514,V515=V515,V516=V516,V517=V517,
                                V518=V518,V519=V519,V520=V520,V521=V521,V522=V522,V523=V523,V524=V524,V525=V525,V526=V526,V527=V527,V528=V528,
                                V529=V529,V530=V530,V531=V531,V532=V532,V533=V533,V534=V534,V535=V535,V536=V536,V537=V537,V538=V538,V539=V539,
                                V540=V540,V541=V541,V542=V542,V543=V543,V544=V544,V545=V545,V546=V546,V547=V547,V548=V548,V549=V549,V550=V550,
                                V551=V551,V552=V552,V553=V553,V554=V554,V555=V555,V556=V556,V557=V557,V558=V558,V559=V559,V560=V560,V561=V561,
                                V562=V562,V563=V563,V564=V564,V565=V565,V566=V566,V567=V567,V568=V568,V569=V569,V570=V570,V571=V571,V572=V572,
                                V573=V573,V574=V574,V575=V575,V576=V576,V577=V577,V578=V578,V579=V579,V580=V580,V581=V581,V582=V582,V583=V583,
                                V584=V584,V585=V585,V586=V586,V587=V587,V588=V588,V589=V589,V590=V590,V591=V591,V592=V592,V593=V593,V594=V594,
                                V595=V595,V596=V596,V597=V597,V598=V598,V599=V599,V600=V600,V601=V601,V602=V602,V603=V603,V604=V604,V605=V605,
                                V606=V606,V607=V607,V608=V608,V609=V609,V610=V610,V611=V611,V612=V612,V613=V613,V614=V614,V615=V615,V616=V616,
                                V617=V617,V618=V618,V619=V619,V620=V620,V621=V621,V622=V622,V623=V623,V624=V624,V625=V625,V626=V626,V627=V627,
                                V628=V628,V629=V629,V630=V630,V631=V631,V632=V632,V633=V633,V634=V634,V635=V635,V636=V636,V637=V637,V638=V638,
                                V639=V639,V640=V640,V641=V641,V642=V642,V643=V643,V644=V644,V645=V645,V646=V646,V647=V647,V648=V648,V649=V649,
                                V650=V650,V651=V651,V652=V652,V653=V653,V654=V654,V655=V655,V656=V656,V657=V657,V658=V658,V659=V659,V660=V660,
                                V661=V661,V662=V662,V663=V663,V664=V664,V665=V665,V666=V666,V667=V667,V668=V668,V669=V669,V670=V670,V671=V671,
                                V672=V672,V673=V673,V674=V674,V675=V675,V676=V676,V677=V677,V678=V678,V679=V679,V680=V680,V681=V681,V682=V682,
                                V683=V683,V684=V684,V685=V685,V686=V686,V687=V687,V688=V688,V689=V689,V690=V690,V691=V691,V692=V692,V693=V693,
                                V694=V694,V695=V695,V696=V696,V697=V697,V698=V698,V699=V699,V700=V700,V701=V701,V702=V702,V703=V703,V704=V704,
                                V705=V705,V706=V706,V707=V707,V708=V708,V709=V709,V710=V710,V711=V711,V712=V712,V713=V713,V714=V714,V715=V715,
                                V716=V716,V717=V717,V718=V718,V719=V719,V720=V720,V721=V721,V722=V722,V723=V723,V724=V724,V725=V725,V726=V726,
                                V727=V727,V728=V728,V729=V729,V730=V730,V731=V731,V732=V732,V733=V733,V734=V734,V735=V735,V736=V736,V737=V737,
                                V738=V738,V739=V739,V740=V740,V741=V741,V742=V742,V743=V743,V744=V744,V745=V745,V746=V746,V747=V747,V748=V748,
                                V749=V749,V750=V750,V751=V751,V752=V752,V753=V753,V754=V754,V755=V755,V756=V756,V757=V757,V758=V758,V759=V759,
                                V760=V760,V761=V761,V762=V762,V763=V763,V764=V764,V765=V765,V766=V766,V767=V767,V768=V768,V769=V769,V770=V770,
                                V771=V771,V772=V772,V773=V773,V774=V774,V775=V775,V776=V776,V777=V777,V778=V778,V779=V779,V780=V780,V781=V781,
                                V782=V782,V783=V783,V784=V784 )
    prediction <- predict(model.small, newdata = newdata.frame, type = "response")
    as.numeric(as.character(prediction))
}
debug(predict.small)
predict.small(as.numeric(d.test[1,-785])) #### geht nicht weil dies ein VEKTOR ist, muss den Vektor in 784 einzelne Zahlen umwandeln!!!!!


##########################################################
#                 Consume Service in R                   #
##########################################################

# Print capabilities that define the service holdings: service 
# name, version, descriptions, inputs, outputs, and the 
# name of the function to be consumed

print(api.small$capabilities())

# Consume service by calling function, `manualTransmission`
# contained in this service
api.small$consume(rep(0, 784))
# result <- api.small$predictsmall(as.numeric(d.test[1,-785])) # output NULL (resp. when looking at str(result) -> error message status 400, "The value System.Int32[] cannot be converted to type numeric") 
result <- api.small$predictsmall(rep(0, 784)) # output NULL (resp. when looking at str(result) -> error message status 400, "The value System.Int32[] cannot be converted to type numeric") 

result <- api.empty$predict.empty(rep(0, 784)) # output NULL (resp. when looking at str(result) -> error message status 400, "The value System.Int32[] cannot be converted to type numeric") 

result <- api.test$test(6) #-> works
str(result)
# Print response output named `label`
print(result$output("label")) #

##########################################################
#         Get Service-specific Swagger File in R         #
##########################################################

# During this authenticated session, download the  
# Swagger-based JSON file that defines this service
swagger <- api$swagger()
cat(swagger, file = "swagger.json", append = FALSE)

# Now share this Swagger-based JSON so others can consume it


##########################################################
#          Delete service version when finished          #
##########################################################

# User who published service or user with owner role can
# remove the service when it is no longer needed
status <- deleteService(serviceName, "v1.0.0")
status

##########################################################
#                   Log off of R Server                  #
##########################################################

# Log off of R Server
remoteLogout()


# Return metadata for all services hosted on this server
serviceAll <- listServices()

# Return metadata for all versions of service "mtService" 
mtServiceAll <- listServices("mtService")

# Return metadata for version "v1" of service "mtService" 
mtService <- listServices("mtService", "v1")

# View service capabilities/schema for mtService v1. 
# For example, the input schema:
#   list(name = "wt", type = "numeric")
#   list(name = "dist", type = "numeric")
print(mtService)