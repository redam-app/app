<?php

declare(strict_types=1);

namespace App\Models\Process;

use Symfony\Component\Console\Output\OutputInterface;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class CreateUser extends Base
{
    /**
     * @param array<int, string> $servers
     */
    public function execute(
        OutputInterface $output,
        array $servers,
        string $rootUser,
        string $rootPassword,
        bool $super,
        bool $grant,
        bool $initial
    ): void {
        $databaseServer = sprintf('database:%s', count($servers) > 0 ? implode(',', $servers) : 'all');

        $this->run(
            $output,
            'create-user.sh',
            ['databaseType', 'databaseVersion'],
            [$databaseServer],
            [
                'databaseRootUser' => $rootUser,
                'databaseRootPassword' => $rootPassword,
            ]
        );

        if ($grant || $initial) {
            $this->run(
                $output,
                'grant-user.sh',
                ['databaseType', 'databaseVersion'],
                [$databaseServer],
                [
                    'databaseRootUser' => $rootUser,
                    'databaseRootPassword' => $rootPassword,
                ]
            );
        }

        if ($super) {
            $this->run(
                $output,
                'grant-super.sh',
                ['databaseType', 'databaseVersion'],
                [$databaseServer],
                [
                    'databaseRootUser' => $rootUser,
                    'databaseRootPassword' => $rootPassword,
                ]
            );
        }

        if ($initial) {
            $this->run(
                $output,
                'create-database.sh',
                ['databaseType', 'databaseVersion'],
                [$databaseServer],
                []
            );
        }
    }
}
