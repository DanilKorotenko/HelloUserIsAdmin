//
//  main.m
//  HelloUserIsAdmin
//
//  Created by Danil Korotenko on 6/3/21.
//

#import <Foundation/Foundation.h>
#import <Collaboration/Collaboration.h>

BOOL isUserAdmin(NSString *aUserName);
gid_t getAdminIdentityGroupID(void);


gid_t getAdminIdentityGroupID()
{
    CSIdentityQueryRef groupQuery = CSIdentityQueryCreateForName(
        kCFAllocatorDefault, CFSTR("admin"), kCSIdentityQueryStringEquals,
        kCSIdentityClassGroup, CSGetLocalIdentityAuthority());

    CSIdentityQueryExecute(groupQuery, kCSIdentityQueryIncludeHiddenIdentities, NULL);
    CFArrayRef groupQueryResults = CSIdentityQueryCopyResults(groupQuery);

    gid_t adminGroupId = 0;

    if (groupQueryResults)
    {
        CFIndex resultsCount = CFArrayGetCount(groupQueryResults);

        if (resultsCount == 1)
        {
            CSIdentityRef adminGroupIdentity =
                (CSIdentityRef)CFArrayGetValueAtIndex(groupQueryResults, 0);
            adminGroupId = CSIdentityGetPosixID(adminGroupIdentity);
        }

        CFRelease(groupQueryResults);
    }

    return adminGroupId;
}

BOOL isUserAdmin(NSString *aUserName)
{
    CBIdentity *userIdentity = [CBIdentity identityWithName:aUserName
        authority:[CBIdentityAuthority defaultIdentityAuthority]];

    CBGroupIdentity *groupIdentity = [CBGroupIdentity
        groupIdentityWithPosixGID:getAdminIdentityGroupID()
        authority:[CBIdentityAuthority localIdentityAuthority]];

    BOOL isAdmin = NO;

    if (groupIdentity != nil)
    {
        // check if the user is currently a member of the admin group
        isAdmin = [userIdentity isMemberOfGroup:groupIdentity];
    }

    return isAdmin;
}

int main(int argc, const char * argv[])
{
    BOOL isAdmin = NO;

    @autoreleasepool
    {
        NSString *userName = NSUserName();
        isAdmin = isUserAdmin(userName);
        NSString *userRole = (isAdmin ? @"Admin" : @"Standart User");

        NSLog(@"User: %@ is %@", userName, userRole);
    }

    return (isAdmin ? 0 : 1);
}
