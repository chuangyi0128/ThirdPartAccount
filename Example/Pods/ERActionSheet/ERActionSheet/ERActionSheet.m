//
//  ERActionSheet.m
//  ERActionSheet
//
//  Created by Mac on 12-11-30.
//  Copyright (c) 2012年 SongLi. All rights reserved.
//

#import "ERActionSheet.h"
#import "ERActionSheetCell.h"

@interface ERActionSheet () <ERActionSheetCellDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *cellArray;
@property (weak, nonatomic) UIView *superView;
@property (assign, nonatomic) CGSize cellSize;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) NSMutableArray *infoArray;
@end

#define CancelButtonLeft        20
#define CancelButtonToBottom    12
#define PageControlLeft         141
#define PageControlToBottom     42
#define ScrollViewLeft          10
#define ScrollViewToBottom      60


@implementation ERActionSheet

#pragma mark - View Life Circle
- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.25f]];
        [self setAutoresizesSubviews:NO];
        
        self.cellArray = [[NSMutableArray alloc] init];
        self.infoArray = [NSMutableArray array];
        self.backView = [[UIView alloc] init];
        [self.backView setBackgroundColor:[UIColor clearColor]];
        [self.backView setAlpha:0.0f];
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview:self.backgroundImage];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 5, 300, 255)];
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setBounces:YES];
        [self.scrollView setAlwaysBounceHorizontal:YES];
        [self.scrollView setAlwaysBounceVertical:NO];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView setDelegate:self];
        [self addSubview:self.scrollView];
        
        self.pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(141, 250, 38, 36)];
        [self.pageController setUserInteractionEnabled:NO];
        [self addSubview:self.pageController];
        
        self.buttonCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.buttonCancel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9f]];
        [self.buttonCancel.layer setCornerRadius:5];
        [self.buttonCancel.layer setMasksToBounds:YES];
        [self.buttonCancel addTarget:self action:@selector(handleCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonCancel setFrame:CGRectMake(CancelButtonLeft, 276, CGRectGetWidth(self.bounds) - CancelButtonLeft * 2, 32)];
        [self.buttonCancel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.buttonCancel setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self addSubview:self.buttonCancel];
    }
    return self;
}

- (id)initWithDelegate:(id<ERActionSheetDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}


#pragma mark - Private Methods
- (void)autoLayout:(CGSize)superViewSize
{
    CGSize scrolViewSize = CGSizeMake(superViewSize.width-20, superViewSize.height-75);
    NSInteger rowsCount, columnsCount, rowsPerPage, pagesCount;
    CGFloat gapX, gapY;
    
    if (scrolViewSize.width < self.cellSize.width) {
        //todo: scale cell to fit
        columnsCount = 1;
        rowsCount = [self.cellArray count];
    }
    
    columnsCount = scrolViewSize.width / self.cellSize.width;
    rowsCount = [self.cellArray count] / columnsCount + ([self.cellArray count]%columnsCount==0 ? 0 : 1);
    rowsPerPage = scrolViewSize.height / self.cellSize.height;
    pagesCount = rowsCount / rowsPerPage + (rowsCount%rowsPerPage==0 ? 0 : 1);
    
    // adjust UI
    CGRect rect = [self frame];
    if (1 == pagesCount) {
        scrolViewSize.height = rowsCount * self.cellSize.height;
        rect.size.height = scrolViewSize.height + 15 + PageControlToBottom;
    } else {
        scrolViewSize.height = rowsPerPage * self.cellSize.height;
        rect.size.height = scrolViewSize.height + 10 + ScrollViewToBottom;
    }
    [self.scrollView setFrame:CGRectMake(ScrollViewLeft, 10, scrolViewSize.width, scrolViewSize.height)];
    [self.buttonCancel setFrame:CGRectMake(CancelButtonLeft, rect.size.height-self.buttonCancel.frame.size.height-CancelButtonToBottom, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height)];
    [self.pageController setFrame:CGRectMake(PageControlLeft, rect.size.height-self.pageController.frame.size.height-PageControlToBottom, self.pageController.frame.size.width, self.pageController.frame.size.height)];
    [self.backgroundImage setFrame:rect];
    [self setFrame:rect];
    
    gapX = (scrolViewSize.width - columnsCount * self.cellSize.width) / (columnsCount + 1);
    gapY = (scrolViewSize.height - (rowsCount<rowsPerPage ? rowsCount : rowsPerPage) * self.cellSize.height) / (rowsCount + 1);
    NSAssert(gapX>=0&&gapY>=0, @"ERActionSheet Scrolview Margin Error!! (gapX=%f, gapY=%f)", gapX, gapY);
    
    [self.pageController setCurrentPage:0];
    [self.pageController setNumberOfPages:(pagesCount==1 ? 0 : pagesCount)];
    [self.scrollView setContentSize:CGSizeMake(scrolViewSize.width*pagesCount, scrolViewSize.height)];
    self.scrollView.scrollEnabled = (pagesCount > 1);
    
    for (int index = 0; index < self.cellArray.count; index++) {
        ERActionSheetCell *cell = self.cellArray[index];
        NSInteger row = index / columnsCount % rowsPerPage;
        NSInteger column = index % columnsCount;
        NSInteger page = index / columnsCount / rowsPerPage;
        CGFloat x = gapX * (column + 1) + column * self.cellSize.width + page * scrolViewSize.width;
        CGFloat y = gapY * (row + 1) + row * self.cellSize.height;
        CGRect frame = CGRectOffset(cell.frame, x, y);
        [cell setFrame:frame];
        [self.scrollView addSubview:cell];
    }
}


#pragma mark - ERActionSheetCellDelegate
- (void)didClickCell:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(ERActionSheet:clickedButtonAtIndex:withInfo:)]) {
        NSUInteger index = [self.cellArray indexOfObject:sender];
        if (index != NSNotFound) {
            [self.delegate ERActionSheet:self clickedButtonAtIndex:index withInfo:self.infoArray[index]];
        }
        [self handleCancel:nil];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSInteger currPage = (aScrollView.contentOffset.x / aScrollView.frame.size.width) + 0.5f;
    [self.pageController setCurrentPage:currPage];
}


#pragma mark - Public Methods

- (void)addButtonWithTitle:(NSString*)title image:(UIImage*)image info:(NSDictionary *)info
{
    ERActionSheetCell *cell = [[ERActionSheetCell alloc] initWithDelegate:self];
    [cell setImage:image];
    [cell setTitle:title];
    [self.cellArray addObject:cell];
    self.cellSize = cell.frame.size;

    if (info == nil) {
        info = [NSDictionary dictionary];
    }
    [self.infoArray addObject:info];
}

- (void)showInView:(UIView*)superView
{
    if ([self.cellArray count] == 0) {
        return;
    }
    
    self.superView = superView;
    [self autoLayout:superView.frame.size];
    CGRect rect = [self frame];
    [self.backView setFrame:CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height)];
    rect.origin.y = self.superView.frame.size.height;
    [self setFrame:rect];
    rect.origin.y -= self.frame.size.height;
    [self.superView addSubview:self.backView];
    [self.superView addSubview:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [self setFrame:rect];
    [self.backView setAlpha:0.25f];
    [UIView commitAnimations];
}


#pragma mark - Actions
- (void)handleCancel:(id)sender
{
    CGRect rect = [self frame];
    rect.origin.y = self.superView.frame.size.height;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self setFrame:rect];
                         [self.backView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         [self.backView removeFromSuperview];
                         [self removeFromSuperview];
                     }
     ];
}

@end
