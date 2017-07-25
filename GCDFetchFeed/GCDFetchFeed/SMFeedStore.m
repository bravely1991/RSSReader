//
//  SMFeedStore.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMFeedStore.h"
#import "Ono.h"

@interface SMFeedStore()



@end

@implementation SMFeedStore

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

#pragma mark - Interface
- (SMFeedModel *)updateFeedModelWithData:(NSData *)feedData preModel:(SMFeedModel *)preModel{
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:feedData error:nil];
    SMFeedModel *feedModel = [[SMFeedModel alloc] init];
    //原有model需要保留的
    feedModel.feedUrl = preModel.feedUrl;
    feedModel.fid = preModel.fid;
    feedModel.unReadCount = preModel.unReadCount;
    feedModel.des = preModel.des;
    //开始解析
    NSMutableArray *itemArray = [NSMutableArray array];
    for (ONOXMLElement *element in document.rootElement.children) {
        
        //rss2类型
        if ([element.tag isEqualToString:@"channel"]) {
            for (ONOXMLElement *channelChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"title"]) {
                    feedModel.title = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"link"]) {
                    feedModel.link = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"description"]) {
                    feedModel.des = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"copyright"]) {
                    feedModel.copyright = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"generator"]) {
                    feedModel.generator = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"image"]) {
                    for (ONOXMLElement *channelImage in channelChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:channelImage.tag compareString:@"url"]) {
                            if (channelImage.stringValue.length > 0 && !(preModel.imageUrl.length > 0)) {
                                feedModel.imageUrl = channelImage.stringValue;
                            }
                        }
                    }
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"item"]) {
                    
                    SMFeedItemModel *itemModel = [[SMFeedItemModel alloc] init];
                    for (ONOXMLElement *channelItem in channelChild.children) {
                        
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"link"]) {
                            itemModel.link = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"title"]) {
                            itemModel.title = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"author"]) {
                            itemModel.author = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"category"]) {
                            itemModel.category = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"pubdate"]) {
                            itemModel.pubDate = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"description"]) {
                            itemModel.des = channelItem.stringValue;
                        }
                        
                    }
                    [itemArray addObject:itemModel];
                } //end item
                
            } //end channel
        }
        
        //--------atom类型的处理------
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"title"]) {
            feedModel.title = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"subtitle"]) {
            feedModel.des = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"link"]) {
            feedModel.link = (NSString *)[element valueForAttribute:@"href"];
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"id"]) {
            feedModel.link = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"rights"]) {
            feedModel.copyright = element.stringValue;
        }
        if ([element.tag isEqualToString:@"entry"]) {
            SMFeedItemModel *itemModel = [[SMFeedItemModel alloc] init];
            for (ONOXMLElement *entryChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"link"]) {
                    itemModel.link = (NSString *)[entryChild valueForAttribute:@"href"];;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"title"]) {
                    itemModel.title = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"author"]) {
                    for (ONOXMLElement *authorChild in entryChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:authorChild.tag compareString:@"name"]) {
                            if (authorChild.stringValue.length > 0) {
                                itemModel.author = authorChild.stringValue;
                            }
                        }
                    }
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"updated"]) {
                    itemModel.pubDate = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"content"]) {
                    itemModel.des = entryChild.stringValue;
                }
            }
            [itemArray addObject:itemModel];
        } //end entry
        
        //preModel和feedModel的合并取舍
        if (!(feedModel.imageUrl.length > 0)) {
            feedModel.imageUrl = preModel.imageUrl;
        }
    }
    feedModel.items = itemArray;
    return feedModel;
}

+ (NSMutableArray *)defaultFeeds {
    NSMutableArray *mArr = [NSMutableArray array];
    SMFeedModel *starmingFeed = [[SMFeedModel alloc] init];
    starmingFeed.title = @"绝世战神";
    starmingFeed.feedUrl = @"https://kangyonggan.com/rss/%E7%BB%9D%E4%B8%96%E6%88%98%E9%AD%82(1001%E7%AB%A0-1100%E7%AB%A0).xml";
    starmingFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_starming.png?raw=true";
    [mArr addObject:starmingFeed];
    
    
    
    SMFeedModel *zhihuDaily = [[SMFeedModel alloc] init];
    zhihuDaily.title = @"农门悍女掌家小厨娘(101-200)";
    zhihuDaily.feedUrl = @"https://kangyonggan.com/rss/2.xml";
    zhihuDaily.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_starming.png?raw=true";
    [mArr addObject:zhihuDaily];
    

    
    return mArr;
}

#pragma mark - private
- (BOOL)isEqualToWithDoNotCareLowcaseString:(NSString *)string compareString:(NSString *)compareString {
    if ([string.lowercaseString isEqualToString:compareString.lowercaseString]) {
        return YES;
    }
    return NO;
}

@end
