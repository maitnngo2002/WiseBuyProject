//
//  PostCell.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/20/22.
//

#import "PostCell.h"

@implementation PostCell

- (void)setPost:(Post *)post {    
    self.itemNameLabel.text = post.itemName;
    self.priceLabel.text = post.price;
    self.sellerLabel.text = post.sellerName;
}

@end
