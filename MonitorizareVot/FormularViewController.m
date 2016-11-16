//
//  FormularViewController.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 30/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "FormularViewController.h"
#import "QuestionViewController.h"

@interface FormularViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *questionsCollectionView;

@end

@implementation FormularViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.questionsCollectionView registerNib:[UINib nibWithNibName:@"QuestionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"questionCell"];
    // Do any additional setup after loading the view.
}

#pragma mark - CollectionViewDatasource&Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"questionCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QuestionViewController *questionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"questionVC"];
    [self.navigationController pushViewController:questionVC animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
