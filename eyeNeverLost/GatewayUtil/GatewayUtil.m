//
//  GatewayUtil.m
//  
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



//#define AVK_HOST "atlant-inform.dyndns.org"
#define AVK_HOST "shluz.tygdenakarte.ru:60080"

#import "GatewayUtil.h"

@implementation BeaconObj

@synthesize name,uid,date,latitude,longitude,status,accuracy; 

+(BeaconObj*) createWithString:(NSString*)src {
    BeaconObj *obj = [[BeaconObj alloc] init];
    NSRange rg;

    NSRange lhs = [src rangeOfString:@"("];
    NSRange rhs = [src rangeOfString:@")"];
    rg.location =  lhs.location+1;
    rg.length   =  rhs.location - lhs.location - 1;
    
    obj.name = [src substringToIndex:lhs.location];
    obj.uid  = [src substringWithRange:rg];
    
    return obj;
}

+(BeaconObj*) createWithLocationString:(NSString*)src {
    BeaconObj *obj = [[BeaconObj alloc]init];
    
    netlog(@"Location String: %@\n",src);
    NSArray *arTokens = nil;
    arTokens = [src componentsSeparatedByString:@"^"]; 	
    obj.latitude = [NSNumber numberWithDouble:[[arTokens objectAtIndex:0] doubleValue]];
    obj.longitude = [NSNumber numberWithDouble:[[arTokens objectAtIndex:1] doubleValue]];
    obj.accuracy  = [NSNumber numberWithDouble:[[arTokens objectAtIndex:2] doubleValue]];
    obj.date = [arTokens objectAtIndex:3];
    obj.status = [arTokens objectAtIndex:4];
    return obj;
}
  
+(BeaconObj*) createWithNameAndId:(NSString*)src {
    BeaconObj *obj = [[BeaconObj alloc]init];
    netlog(@"addBeacon reasponse %@\n",src);
    NSArray *arTokens = [src componentsSeparatedByString:@"^"];
    obj.name = [arTokens objectAtIndex:0];
    obj.uid  = [arTokens objectAtIndex:1];
    return obj;
}

@end


@implementation GatewayUtil

@synthesize response,deviceID;

-(id)init {
    self = [super init];
    if ( self != nil )
    {
        // при парсинге ответа сюда упадут значения из <msg> и <rc>
        self.response = [[NSMutableDictionary alloc]init];
        self.deviceID = [UIDevice currentDevice].uniqueIdentifier;
        //netlog(@"GatewayUtil Initialized: UID = %@\n",self.deviceID);
    }
    return self;
}

/*
    Либо проверка на существование логинпароля либо для активации 
    телефона с beaconID
 */
-(BOOL) Authorization:(NSString *)login password:(NSString*)pass beaconID:(NSString*)beaconID {
    
    NSString *sRequest = nil;
    NSString *sURL = nil;
    
    if ( beaconID == nil ) {
        sRequest = [NSString stringWithString:@"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.phone_authorization</name><index></index><param>%@^%@</param></function></request>"];
        sURL = [NSString stringWithFormat:sRequest,login,pass];
   }
    else {
        sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.phone_authorization</name><index></index><param>%@^%@^%@^-%@</param></function></request>";
        sURL = [NSString stringWithFormat:sRequest,login,pass,beaconID,self.deviceID];
    }
    			
    if ( [self sendRequestWithActivity:sURL] == NO ) {
        return NO;
    }
        
    // вызов с простой проверкой существования пользователя
    if ( beaconID == nil )
        netlog(@"Authorization status: %@ [%@]\n",[response objectForKey:@"rc"],[response objectForKey:@"msg"]);
    else // активация телефона с биконом
        netlog(@"Activation status: %@ [%@]\n",[response objectForKey:@"rc"],[response objectForKey:@"msg"]);
    
    // проверка на результат
    NSString *rc = [self.response objectForKey:@"rc"];
    int nRes = [rc intValue];
    
    return nRes >= 0;
}

-(BeaconObj*)addBeacon:(NSString*)login password:(NSString*)pass beaconName:(NSString*)name {

    NSString* sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.add_beacon</name><index>1</index><param>%@^%@^%@^%@</param></function></request>";
    
    NSString* sURL = [NSString stringWithFormat:sRequest,login,pass,name,self.deviceID]; 
    
    if ( [self sendRequest:sURL] == NO )
        return nil;
    
    // проверка на результат
    NSString *rc = [self.response objectForKey:@"rc"];
    NSString *msg = [self.response objectForKey:@"msg"];
    int nRes = [rc intValue];
    if ( nRes >= 0 ) 
        return [BeaconObj createWithNameAndId:msg];
    
    return nil;
}

-(BeaconObj*)fastRegistration:(NSString*)sLogin password:(NSString*)sPassword beaconName:(NSString*)sName {
    
    NSString* sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.user_registration</name><index>1</index><param>%@^%@^%@^%@</param></function></request>";
    NSString *sURL = [NSString stringWithFormat:sRequest,sLogin , sPassword , sName,self.deviceID];
    
    if ( [self sendRequest:sURL] == NO ) 
        return nil;

    NSString *rc = [self.response objectForKey:@"rc"];
    NSString *msg = [self.response objectForKey:@"msg"];
    int nRes = [rc intValue];
    if ( nRes >= 0 ) {
        return [BeaconObj createWithNameAndId:msg];
    }
    return nil;
}
 /*
 Возвращает список дружбанов для телефона с данным beaconID
 юзается в eyeMapViewController
 */
-(NSMutableArray*)getSeatMates:(NSString*)beaconID {
 
    NSString *sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG_2.get_seatmates</name><index>1</index><param>%@</param></function></request>";
    
    NSString *sURL = [NSString stringWithFormat:sRequest,beaconID];
    
    if ( [self sendRequestWithActivity:sURL] == NO ) {
        return nil;
    }

    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *msg = [response objectForKey:@"msg"]; 
    if ( msg == nil  || [msg length] == 0 )
        return nil;
    
    return [self beaconParseResponse:msg outList:list];
}

/*
    Возващает координаты для отображения дружбана на карте
    юзается из eyeMapViewController
 */
-(BeaconObj*)getLastBeaconLocation:(NSString*)beaconID {
    NSString *sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG_2.get_last_beacon_location</name><index>1</index><param>%@</param></function></request>";
    
    NSString *sURL = [NSString stringWithFormat:sRequest,beaconID];
    
    if ( [self sendRequestWithActivity:sURL] == NO ) {
        netlog(@"Failed to request last beacon location\n");
        return nil;
    }
    
    // строка с координатами, датой и статусом для дружбана
    NSString *msg = [self.response objectForKey:@"msg"];
    int rc = [[self.response objectForKey:@"rc"] intValue];
    if ( rc != 0 ) {
        //alert(@"Ошибка",@"Ошибка на уровне базы: %@",msg);
        return nil;
    }
    netlog(@"getBeaconLocation(%@)=>%d[%@]\n",beaconID,rc,msg);
    // парсится эта прелесть в конструкоторе
    BeaconObj *beaconObj = [BeaconObj createWithLocationString:msg];
    
    return beaconObj;   
}

/*
 Список телефонов для пользователя с логинпаролем
 служит для активации 
 юзается из eyeFirstViewController
 */
-(NSMutableArray*)getBeaconList:(NSString *)login password:(NSString*)pass {
    
    NSString *sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.list_beacons</name><index>1</index><param>%@^%@</param></function></request>";
 
    
    NSString *sURL = [NSString stringWithFormat:sRequest,login,pass];
    
    if ( [self sendRequestWithActivity:sURL] == NO ) {
        return nil;
    }
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    // строка со списком имени и идентификатором телефона   
    NSString *msg = [response objectForKey:@"msg"];    
    return [self beaconParseResponse:msg outList:list];
}

/*
 Отсылает post c офф-лайн файлом,ошибки сбрасываются в лог
 никакой асинхронности, эта хрень и так вызывается в контексте NSBlockOperation
 */
-(BOOL)sendOfflineFile:(NSString*)offlineFile {

    netlog(@"Sending history file\n");
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    NSURL *cgiUrl = [NSURL URLWithString:@"http://" AVK_HOST "/cgi-bin/LocationFromFile_02"];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:cgiUrl];
    
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *sBoundary = @"0xC0de4F00d";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",sBoundary];
    [postRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",sBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device\";\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",[uDef stringForKey:@"beaconID"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",sBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"inputfile\"; filename=\"%@\"\r\n",offlineFile] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithContentsOfFile:offlineFile]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",sBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postRequest setHTTPBody:body];

    NSURLResponse *resp = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&resp error:&error];
    BOOL fOK = YES;
    if ( data == nil ) {
        netlog(@"Failed to send history file %@\n",error != nil?[error description]:@"");
        return NO;
    } else {
        NSHTTPURLResponse *httpResponse;
        httpResponse = (NSHTTPURLResponse *)resp;
        int statusCode = [httpResponse statusCode];
        NSString *statusString = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        netlog(@"HTTP Status code was %d ( %@ )\n", statusCode,statusString);
        if ( statusCode == 200 ) // HTTP OK
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ( [fileManager removeItemAtPath:offlineFile error:&error] == NO )
                netlog(@"Failed to unlink the history file %@\n",[error description]);
        } else {
            netlog(@"HTTP response doesn't seem okay...\n",statusString );
            fOK = NO;
        }
        NSString *sReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        netlog(@"Dump REPLY\n%@\n",sReply);
    } // data received
    return fOK;
}

/*
 Отсылает позицию на сервак либо дампит ее в офф-лайн файл
 */
-(BOOL)saveLocation:(NSString*)beaconID longitude:(float)lng latitude:(float)lat precision:(float)prec status:(NSString*)stat date:(NSDate*)when error:(NSString**)error
{
    *error = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-YYYY_HH:mm:ss"];
    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *offlineFile = [docsPath stringByAppendingPathComponent:@"LocationHistory.log"];
    
    NSString *sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.saveLocation_Phone_IPhnone_ext</name><index>1</index><param>%@^%f^%f^%f^-%@^%@^D%@^E%d</param></function></request>";
    
    int battLevel = [GatewayUtil getBatteryLevel];
    NSString *sDate = [dateFormatter stringFromDate:when]; 
    netlog(@"GPS Timestamp %@, charge %d\n",sDate,battLevel);
    NSString *sURL = [NSString stringWithFormat:sRequest,beaconID,lng,lat,prec,self.deviceID,stat,sDate,battLevel];
 
    if ( [ GatewayUtil isConnected ] == YES ) {
        // Если законнектились, пытаемся отослать офф-лайновый файлик
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:offlineFile] == YES) {        
            [self sendOfflineFile:offlineFile];
        }
        // и отправляем обычный запрос на апдейт позиции
        if ( [self sendRequest:sURL] == NO )
            return NO;
            
        NSString *rc = [self.response objectForKey:@"rc"];
        NSString *msg = [self.response objectForKey:@"msg"];
        int rcVal = [rc intValue];
        if ( rcVal < 0 ) {
            *error = [NSString stringWithString:msg];
            netlog(@"Logic Error: %@\n",msg);
        }
    } else { 
        // Нету интернету...дампим позицию в офф-лайн файлик
        netlog(@"Dumping location to file: %@\n",offlineFile);
        
        
        NSError *error = nil;
        NSString *sData = @"";
        NSStringEncoding encoding;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // Если файл уже есть, то слопаем его контент,
        // ибо [NSString writeToFile] - перезаписывает файл а не аппендит
        if ([fileManager fileExistsAtPath:offlineFile] == YES) {        
            sData = [NSString stringWithContentsOfFile:offlineFile usedEncoding:&encoding error:&error];
        } 
        
        sData = [sData stringByAppendingFormat:@"-1^%@^%f^%f^%f^-%@^%@^D%@^E%@\n",beaconID,lng,lat,prec,self.deviceID,stat,sDate,battLevel];

        // Перезаписываем файло
        if ([sData writeToFile:offlineFile atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO )
        {
            if ( error != nil ) {
                netlog(@"Dumping error: %@\n",[error description]);
                return NO;
            }
        } else 
            netlog(@"Dumped: [%@]\n",sData);
    } // без инета
    
    return YES;
}

/*
 Вроде как атавизим, но возвращает период обновления позиций в базе
 нах не нужен,ИМХО
 */
-(int)getFrequency:(NSString*)beaconID {
    
    NSString *sRequest = @"http://" AVK_HOST "/cgi-bin/Location_02?document=<request><function><name>PHONEFUNC_PKG.get_frequency</name><index>1</index><param>%@</param></function></request>";    

    NSString *sURL = [NSString stringWithFormat:sRequest,beaconID];
    
    if ( [self sendRequestWithActivity:sURL] == NO ) {
        netlog(@"Ошибка получения частоты обновления\n");
        return -1;
    }
    
    return [[response objectForKey:@"rc"] integerValue];
}

/*
 Общий метод отправки любого запроса на сервак
 + проверка он доступность сети
 */
-(BOOL) sendRequestWithActivity:(NSString*)sURL {
    if ( [GatewayUtil isConnected] == NO ) {
        alert(@"Ошибка",@"Нет подключения к сети");
        return NO;
    }
  return [self sendRequest:sURL];
}

/*
 Отсылает синхронный запрос на сервак
 результат запроса заносит в словарь self.response ( <msg>  и <rc> )
 */

-(BOOL) sendRequest:(NSString*)sURL {

    NSError *error = nil;
    
    sURL = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
    netlog(@"sending: [%@]\n",sURL);

    NSData *xmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:sURL] options:NSDataReadingUncached error:&error];
    
    if ( xmlData == nil || [xmlData length] == 0 ) {
        if ( error != nil ) 
            [response setObject:[error description] forKey:@"msg"];
         else 
            [response setObject:@"Ошибка сети, повторите попытку позже" forKey:@"msg"];
        return NO;
    }
    
    netlog(@"response length = %d\n",[xmlData length]);
    netsend(xmlData);
    
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:xmlData error:&error];
    if ( tbxml == nil ) {
        netlog_alert(@"Failed to parse xml: %@\n",[error description]);
        return NO;
    }
    
    TBXMLElement *root = tbxml.rootXMLElement;
    if ( root == nil ) {
        netlog_alert(@"Cannot find root element...(<response>)\n");
        return NO;
    }
    
    TBXMLElement *result  = [self xmlGetElement:@"result" parentNode:root];
    if ( result == nil ) 
        return NO;
        
    TBXMLElement *rc = [self xmlGetElement:@"rc" parentNode:result];
    if ( rc == nil ) 
        return NO;
        
    // optional
    TBXMLElement * msg    = [self xmlGetElement:@"msg" parentNode:result];
 
    [response setValue:[TBXML textForElement:rc] forKey:@"rc"];
    if ( msg != nil )
        [response setValue:[TBXML textForElement:msg] forKey:@"msg"];
    else
        [response setValue:@"" forKey:@"msg"];
    
    return YES;
}


/*
 Вспомогательный метод для создания массива списка телефонов зарагестрированных на пользователя
 юзается из [GatewatUtil getBeaconList
 */
-(NSMutableArray*) beaconParseResponse:(NSString *)srcStr outList:(NSMutableArray *)list {
    
    NSRange rg = [srcStr rangeOfString:@"^"];
    if ( rg.length == 0 ) {
        BeaconObj *obj = [BeaconObj createWithString:srcStr];
        [list addObject:obj];
        return list;
    }
    BeaconObj *obj = [BeaconObj createWithString:[srcStr substringToIndex:rg.location]];
    [list addObject:obj];
    
    srcStr = [srcStr substringFromIndex:rg.location+1];
    
    return [self beaconParseResponse:srcStr outList:list];
}


-(TBXMLElement*) xmlGetElement:(NSString*)sName parentNode:(TBXMLElement*)parent {
    NSError *error = nil;
    TBXMLElement *result  = [TBXML childElementNamed:sName parentElement:parent error:&error];
    if ( result != nil )
        return result;
    
    if ( [sName compare:@"msg"] == 0 )
        return nil;
    
    if ( error != nil )
        netlog_alert(@"Cannot find <%@> tag. (%@)",sName,[error description]);
    else 
        netlog_alert(@"Cannot find <%@> tag. (%@)",sName);

    return nil;
}

+(int) getBatteryLevel {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float level = [[UIDevice currentDevice] batteryLevel];
    return (int)(level * 100);
}


+ (BOOL) isConnected  {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    BOOL isReachable = (flags & kSCNetworkFlagsReachable) == kSCNetworkFlagsReachable;
    //BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    //BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	netlog(@"Connected ? %d\n",isReachable);
    return isReachable;
}


@end
