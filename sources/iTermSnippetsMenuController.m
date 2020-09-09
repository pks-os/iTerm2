//
//  iTermSnippetsMenuController.m
//  iTerm2SharedARC
//
//  Created by George Nachman on 9/8/20.
//

#import "iTermSnippetsMenuController.h"

@implementation iTermSnippetsMenuController {
    IBOutlet NSMenuItem *_menu;
}

- (void)awakeFromNib {
    [iTermSnippetsDidChangeNotification subscribe:self selector:@selector(snippetsDidChange:)];
    [self reload];
}

- (void)snippetsDidChange:(iTermSnippetsDidChangeNotification *)notification {
    switch (notification.mutationType) {
        case iTermSnippetsDidChangeMutationTypeEdit:
            [self reloadIndex:notification.index];
            break;
        case iTermSnippetsDidChangeMutationTypeDeletion:
            [self deleteIndexes:notification.indexSet];
            break;
        case iTermSnippetsDidChangeMutationTypeInsertion:
            [self insertAtIndex:notification.index];
            break;
        case iTermSnippetsDidChangeMutationTypeMove:
            [self moveIndexes:notification.indexSet to:notification.index];
            break;
        case iTermSnippetsDidChangeMutationTypeFullReplacement:
            [self reload];
            break;
    }
    [self reload];
}

- (void)reload {
    [_menu.submenu removeAllItems];
    [[[iTermSnippetsModel sharedInstance] snippets] enumerateObjectsUsingBlock:
     ^(iTermSnippet * _Nonnull snippet, NSUInteger idx, BOOL * _Nonnull stop) {
        [self add:snippet];
    }];
}

- (void)add:(iTermSnippet *)snippet {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:snippet.title
                                                  action:@selector(sendSnippet:)
                                           keyEquivalent:@""];
    item.representedObject = snippet;
    [_menu.submenu addItem:item];
}

- (void)reloadIndex:(NSInteger)index {
    iTermSnippet *snippet = [[[iTermSnippetsModel sharedInstance] snippets] objectAtIndex:index];
    NSMenuItem *item = [_menu.submenu itemAtIndex:index];
    item.title = snippet.title;
    item.representedObject = snippet;
}

- (void)deleteIndexes:(NSIndexSet *)indexes {
    [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [_menu.submenu removeItemAtIndex:idx];
    }];
}

- (void)insertAtIndex:(NSInteger)index {
    [_menu.submenu insertItem:[[NSMenuItem alloc] init] atIndex:index];
    [self reloadIndex:index];
}

- (void)moveIndexes:(NSIndexSet *)sourceIndexes to:(NSInteger)destinationIndex {
    [self deleteIndexes:sourceIndexes];
    for (NSInteger i = 0; i < sourceIndexes.count; i++) {
        [self insertAtIndex:destinationIndex + i];
    }
}

@end
